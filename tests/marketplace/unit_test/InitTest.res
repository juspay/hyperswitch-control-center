open Jest
open Expect

let () = {
  describe("Test", () => {
    let expectedValue = "test"
    let actualValue = "test"

    test("Test", () => {
      expect(actualValue)->toEqual(expectedValue)
    })
  })
}
