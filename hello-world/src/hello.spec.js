const { addListener } = require('./hello')
describe('add listener', () => {
  it('should add a listener', () => {
    const app = {
      get : jest.fn()
    }
    const req = {}
    const res = {
      send: jest.fn()
    }


    addListener(app, 'hello')

    expect(app.get).toHaveBeenCalledWith('/', expect.any(Function))
    const listenerFunction = app.get.mock.calls[0][1]

    listenerFunction(req, res)
    expect(res.send).toHaveBeenCalledWith('hello')
  })
})