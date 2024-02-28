local ReplicatedStorage = game:GetService("ReplicatedStorage")

type Expectation = {
    to: Expectation,
    be: Expectation,
    been: Expectation,
    have: Expectation,
    was: Expectation,
    at: Expectation,

    never: Expectation,

    a: (typeName: string) -> Expectation,
    an: (typeName: string) -> Expectation,
    ok: () -> Expectation,
    equal: (otherValue: any) -> Expectation,
    throw: (message: string) -> Expectation,
    near: (otherValue: number, limit: number?) -> Expectation,
}

-- this will error and there is nothing I can do about it.
describe = describe :: (phrase: string, callback: () -> ()) -> ()
it = it :: (phrase: string, callback: () -> ()) -> ()
expect = expect :: (any) -> Expectation

beforeAll = beforeAll :: (callback: () -> ()) -> ()
afterAll = afterAll :: (callback: () -> ()) -> ()
beforeEach = beforeEach :: (callback: () -> ()) -> ()
afterEach = afterEach :: (callback: () -> ()) -> ()

return function()
    local Iris = require(ReplicatedStorage.Iris)

    local state

    beforeEach(function()
        state = Iris.State()
    end)

    describe("State", function()
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
    end)
end
