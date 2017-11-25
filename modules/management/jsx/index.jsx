function renderReact() {
    ReactDOM.render(<Git />, document.getElementById("git"))
    ReactDOM.render(<Jobs />, document.getElementById("jobs"))
    ReactDOM.render(<Builders />, document.getElementById("builders"))
}