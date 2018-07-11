class PicksView extends React.Component {
    constructor(props) {
        super(props)
        this.state = { picks: [] }
        this.props.mountTo.mount((data) => { this.setState({picks: data}) })
    }

    render() {
        console.log("Render " + this.props.n + " " + this.props.mountTo.url)
        return (
            <table className="picks">
                <thead>
                    <tr>
                        <th> Team </th>
                        <th> Budget </th>
                        <th> Picks </th>
                    </tr>
                </thead>
                <tbody>
                    {
                        this.state.picks.map((team) => {
                            return <tr className={ renderHelper.teamClass(team) }>
                                <td> { renderHelper.renderTeam(team) } </td>
                                <td> { team.spent } ₪</td>
                                <td> { 
                                    team.picks.map((pick) => { 
                                        return pick.team 
                                    }).join(", ")
                                } </td>
                            </tr>
                        })
                    }
                </tbody>
            </table>
        )
    }
}