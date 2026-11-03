local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function()
    local Iris = require(ReplicatedStorage.Iris)

    local state

    beforeEach(function()
        state = Iris.State()
    end)

    describe("State", function()
        it("Should be a state", function()
            expect(state).to.be.a("table")
            expect(state.ID).to.be.a("string")
        end)
        it("SHOULD contain nil", function()
            expect(state:get()).to.equal(nil)
            expect(state.value).to.equal(nil)
            expect(#state.ConnectedFunctions).to.equal(0)
        end)
        it("SHOULD update the value", function()
            expect(state:set(0)).to.be.ok()
            expect(state:get()).to.equal(0)
            expect(state.value).to.equal(0)
        end)
        it("SHOULD update the latest value", function()
            expect(state:set(0)).to.be.ok()
            expect(state:set(state:get() + 1)).to.be.ok()
            expect(state:get()).to.equal(1)
            expect(state.value).to.equal(1)
        end)
        it("SHOULD add a connected function", function()
            expect(state:onChange(function(value)
                expect(value).to.equal(0)
            end))
            expect(state.ConnectedFunctions).to.be.a("table")
            expect(#state.ConnectedFunctions).to.equal(1)
            expect(state.ConnectedFunctions[1]).to.never.equal(nil)
            expect(state.ConnectedFunctions[1]).to.be.a("function")
            expect(state:set(0)).to.be.ok()
        end)
        it("SHOULD chain together two states", function()
            local otherState = Iris.State()
            state:onChange(function(value)
                otherState:set(2 * value)
            end)
            state:set(10)
            expect(otherState:get()).to.equal(20)
        end)
        it("SHOULD disconnect a function", function()
            local number: number = 0
            local disconnect: () -> () = state:onChange(function(value: number)
                number = value
            end)
            expect(disconnect).to.be.a("function")
            expect(#state.ConnectedFunctions).to.equal(1)
            expect(number).to.be.equal(0)
            state:set(1)
            expect(number).to.be.equal(1)
            expect(disconnect()).to.equal(nil)
            expect(#state.ConnectedFunctions).to.equal(0)
            state:set(2)
            expect(number).to.equal(1)
        end)
        it("SHOULD keep other functions connected after a disconnect", function()
            local first, second = 0, 0
            local disconnectFirst = state:onChange(function(value: number)
                first = value
            end)
            state:onChange(function(value: number)
                second = value
            end)
            disconnectFirst()
            -- a repeated disconnect must not remove the other function.
            disconnectFirst()
            expect(#state.ConnectedFunctions).to.equal(1)

            -- connecting after a disconnect must not overwrite an existing function.
            local third = 0
            state:onChange(function(value: number)
                third = value
            end)
            expect(#state.ConnectedFunctions).to.equal(2)

            state:set(5)
            expect(first).to.equal(0)
            expect(second).to.equal(5)
            expect(third).to.equal(5)
        end)
        it("SHOULD allow a function to disconnect itself", function()
            local calls = 0
            local other = 0
            local disconnect
            disconnect = state:onChange(function()
                calls += 1
                disconnect()
            end)
            state:onChange(function(value: number)
                other = value
            end)
            state:set(1)
            state:set(2)
            expect(calls).to.equal(1)
            expect(other).to.equal(2)
        end)
    end)

    describe("Widget states", function()
        local Internal = Iris.Internal
        local widgetState
        local startTick

        local function queued()
            return Internal._discardedTail - Internal._discardedHead + 1
        end

        local function release()
            widgetState.ConnectedWidgets["TestWidget"] = nil
            Internal._releaseState(widgetState)
        end

        beforeEach(function()
            startTick = Internal._cycleTick
            widgetState = Internal._widgetState({ ID = "TestWidget", type = "Test" }, "value", 0)
        end)

        afterEach(function()
            Internal._cycleTick = startTick
            Internal._states[widgetState.ID] = nil
            table.clear(Internal._discardedStates)
            table.clear(Internal._discardedTicks)
            Internal._discardedHead = 1
            Internal._discardedTail = 0
        end)

        it("SHOULD be kept while a widget is connected", function()
            Internal._releaseState(widgetState)
            expect(queued()).to.equal(0)

            Internal._cycleTick += Internal._stateLifetime + 1
            Internal._collectStates()
            expect(Internal._states[widgetState.ID]).to.equal(widgetState)
        end)
        it("SHOULD be kept shortly after the widget is discarded", function()
            release()
            expect(queued()).to.equal(1)

            Internal._cycleTick += Internal._stateLifetime - 1
            Internal._collectStates()
            expect(Internal._states[widgetState.ID]).to.equal(widgetState)
            expect(queued()).to.equal(1)
        end)
        it("SHOULD be removed once the lifetime has passed", function()
            release()

            Internal._cycleTick += Internal._stateLifetime
            Internal._collectStates()
            expect(Internal._states[widgetState.ID]).to.equal(nil)
            expect(queued()).to.equal(0)
        end)
        it("SHOULD be reused if a widget reconnects in time", function()
            release()

            local reused = Internal._widgetState({ ID = "TestWidget", type = "Test" }, "value", 1)
            expect(reused).to.equal(widgetState)

            -- the entry expires, but the state is in use so it must stay.
            Internal._cycleTick += Internal._stateLifetime + 1
            Internal._collectStates()
            expect(Internal._states[widgetState.ID]).to.equal(widgetState)
            expect(queued()).to.equal(0)
        end)
        it("SHOULD use the latest release, not an earlier one", function()
            release()
            Internal._widgetState({ ID = "TestWidget", type = "Test" }, "value", 1)

            -- released again later, so the first queue entry is out of date.
            Internal._cycleTick += Internal._stateLifetime - 5
            release()
            Internal._cycleTick += 10
            Internal._collectStates()
            expect(Internal._states[widgetState.ID]).to.equal(widgetState)

            Internal._cycleTick += Internal._stateLifetime
            Internal._collectStates()
            expect(Internal._states[widgetState.ID]).to.equal(nil)
            expect(queued()).to.equal(0)
        end)
        it("SHOULD only visit the expired states", function()
            local other = Internal._widgetState({ ID = "OtherWidget", type = "Test" }, "value", 0)
            release()
            Internal._cycleTick += 5
            other.ConnectedWidgets["OtherWidget"] = nil
            Internal._releaseState(other)

            -- only the first has expired, the second is still waiting.
            Internal._cycleTick += Internal._stateLifetime - 5
            Internal._collectStates()
            expect(Internal._states[widgetState.ID]).to.equal(nil)
            expect(Internal._states[other.ID]).to.equal(other)
            expect(queued()).to.equal(1)

            Internal._cycleTick += 5
            Internal._collectStates()
            expect(Internal._states[other.ID]).to.equal(nil)
            expect(queued()).to.equal(0)
        end)
        it("SHOULD be kept if a function is connected to it", function()
            widgetState:onChange(function() end)
            release()

            Internal._cycleTick += Internal._stateLifetime + 1
            Internal._collectStates()
            expect(Internal._states[widgetState.ID]).to.equal(widgetState)
        end)
        it("SHOULD never remove a user state", function()
            Internal._releaseState(state)
            expect(queued()).to.equal(0)

            Internal._cycleTick += Internal._stateLifetime + 1
            Internal._collectStates()
            expect(Internal._states[state.ID]).to.equal(state)
        end)
    end)
end
