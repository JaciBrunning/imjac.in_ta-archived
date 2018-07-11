class LeaderboardView extends React.Component {
    constructor(props) {
        super(props)
        this.state = { points: {}, picks: [] }
        frcpoints.mount((data) => { this.setState({points: data}) })
        this.props.mountTo.mount((data) => { this.setState({picks: data}) })
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

    mapMedals() {
        let medals = ["gold", "silver", "bronze"]
        let mapped = this.mapTeams().sort((a,b) => b.total - a.total)
        let medalvals = [... new Set(mapped.map((entry) => entry.total))]
                            .map((t,idx) => { return { total: t, medal: medals[idx] } })
                            .filter((v) => { return v != undefined && v != null })
                            .reduce((m, o) => { m[o.total] = o.medal; return m }, {})
        console.log(medalvals)
        if (Object.keys(medalvals).length < 3) medalvals = {}
        return mapped.map((entry) => {
            entry.medal = medalvals[entry.total]
            return entry
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
                                    this.mapMedals()
                                        .sort((a,b) => b.total-a.total)
                                        .map((entry) => {
                                            return <tr className={renderHelper.teamClass(entry.team)} >
                                                <td> 
                                                    { 
                                                        entry.medal != undefined ?
                                                            <i className={ "fas fa-medal " + entry.medal }> </i> : ""
                                                    } &nbsp;
                                                    { renderHelper.renderTeam(entry.team) }
                                                </td>
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

function renderHostsLeaderboard(id) {
    let el =    <Hideable name="Hosts Leaderboard">
                    <LeaderboardView mountTo={host_picks} />
                </Hideable>
    ReactDOM.render(el, document.getElementById(id))
}