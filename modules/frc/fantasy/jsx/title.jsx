class TitleView extends React.Component {
    constructor(props) {
        super(props)
        this.state = { name: "...", year: "..." }
        frcevent.mount((data) => { this.setState({name: data.name, year: data.year}) })
    }

    render() {
        return (
            <div>
                <h2> Fantasy <i>FIRST</i> - { this.state.year } { this.state.name } </h2>
                <a className="button button-outline" onClick={ (e) => {picks.refresh()} }> Refresh Picks </a>
                <a className="button button-outline" onClick={ (e) => {frcpoints.refresh()} }> Refresh Points </a>
            </div>
        )
    }
}

function renderTitleView(id) {
    ReactDOM.render(<TitleView />, document.getElementById(id))
}