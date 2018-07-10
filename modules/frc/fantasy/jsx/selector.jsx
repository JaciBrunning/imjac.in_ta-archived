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
                                    ("button " + (option == this.state.selected ? "button-clear button-selected" : "button-outline"))
                                } onClick={ (e) => { this.setState({selected: option}) } }>
                                    <i className={"fas fa-" + option.fa }> </i> &nbsp; 
                                    { option.name }
                                </a>
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
            { fa: "trophy", name: "Leaderboard", entry: <LeaderboardView /> },
            { fa: "users", name: "Teams", entry: <PicksView /> },
            { fa: "gamepad", name: "Robots", entry: <PointsView /> }
        ]} />, document.getElementById(id))
}