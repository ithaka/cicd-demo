module.exports = {
  addListener: (app, response) => {
    app.get('/', (req, res) => res.send(response))
  }
}