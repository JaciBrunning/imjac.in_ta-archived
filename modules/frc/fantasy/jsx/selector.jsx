class Selector extends React.Component {
    constructor(props) {
        super(props)
        this.state = { selected: props.options[0] }
    }

    render() {
        return (
            <div className="row">
                <div className="column">
                    <div className="row">
                        {
                            this.props.options.map((option) => {
                                return <a className={
                                    ("button " + (option == this.state.selected ? "button-clear" : "button-outline"))
                                } onClick={ (e) => { this.setState({selected: option}) } }> { option.name } </a>
                            })
                        }
                    </div>
                    <div className="row">
                        {
                            this.state.selected.entry
                        }
                    </div>
                </div>
            </div>
        )
    }
}

function renderDefaultSelector(id) {
    ReactDOM.render(<Selector
        options={[
            { name: "Leaderboard", entry: <LeaderboardView /> },
            { name: "Picks", entry: <PicksView /> },
            { name: "Points", entry: <PointsView /> }
        ]} />, document.getElementById(id))
}