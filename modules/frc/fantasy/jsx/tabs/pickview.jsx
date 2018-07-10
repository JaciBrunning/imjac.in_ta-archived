class PicksView extends React.Component {
    constructor(props) {
        super(props)
        this.state = { picks: [] }
        picks.mount((data) => { this.setState({picks: data}) })
    }

    render() {
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
                            return <tr className={ team.spent > 100 ? "red" : "" }>
                                <td> { team.team } </td>
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