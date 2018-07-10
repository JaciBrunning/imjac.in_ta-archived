class LeaderboardView extends React.Component {
    constructor(props) {
        super(props)
        this.state = { points: {}, picks: [] }
        frcpoints.mount((data) => { this.setState({points: data}) })
        picks.mount((data) => { this.setState({picks: data}) })
    }

    mapTeams() {
        return this.state.picks.map((pickTeam) => {
            let mapped = pickTeam.picks.map((picked) => {
                return { team: picked.team, pts: this.state.points[picked.team] }
            }).filter((val) => { return val.pts != undefined && val.pts != null })

            let total = 0
            let highest_earner = undefined
            if (mapped.length != 0) 
                total = mapped.map(e => e.pts.total).reduce((tot, ent) => tot+ent )

            if (total > 0) {
                mapped.forEach((e) => {
                    if (highest_earner == undefined || e.pts.total > highest_earner.pts.total)
                        highest_earner = e
                })
            }

            return { team: pickTeam, picked: mapped, total: total, highest_earner: highest_earner }
        })
    }

    csvData() {
        return this.mapTeams()
                .sort((a,b) => b.total-a.total)
                .map((entry) => {
                    return [entry.team.team, entry.total]
                })
    }

    render() {
        return (
            <div style={{width: "100%"}}>
                <div className="row">
                    <div className="column">
                        <table className="picks">
                            <thead>
                                <tr>
                                    <th> Team </th>
                                    <th> Points </th>
                                    <th> Highest Points Earner </th>
                                </tr>
                            </thead>
                            <tbody>
                                {
                                    this.mapTeams()
                                        .sort((a,b) => b.total-a.total)
                                        .map((entry) => {
                                            return <tr className={ entry.team.spent > 100 ? "red" : "" } >
                                                <td> { entry.team.team +
                                                    (entry.team.spent > 100 ? " (OVER BUDGET) [DQ]" : "")
                                                } </td>
                                                <td> { entry.total } </td>
                                                <td> {
                                                    (entry.highest_earner == undefined ? "-" : (
                                                        "Team " + entry.highest_earner.team + " (" + entry.highest_earner.pts.total + ")"
                                                    ))
                                                } </td>
                                            </tr>
                                        })
                                }
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        )
    }
}