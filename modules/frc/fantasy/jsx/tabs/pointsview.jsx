class PointsView extends React.Component {
    constructor(props) {
        super(props)
        this.state = { points: {} }
        frcpoints.mount((data) => { this.setState({points: data}) })
    }

    render() {
        return (
            <table className="picks">
                <thead>
                    <tr>
                        <th> Team </th>
                        <th> Points (Total) </th>
                        <th> Wins (Qual + Elim) </th>
                        <th> Ties (Qual only) </th>
                        <th> Points (Draft) </th>
                    </tr>
                </thead>
                <tbody>
                    {
                        Array.from(Object.entries(this.state.points))
                            .sort((a,b) => { return b[1].total - a[1].total })
                            .map((pair) => {
                                return <tr>
                                    <td> { pair[0] } </td>
                                    <td> { pair[1].total } </td>
                                    <td> { pair[1].qwins } + { pair[1].ewins } </td>
                                    <td> { pair[1].ties } </td>
                                    <td> { pair[1].draft } </td>
                                </tr>
                            })
                    }
                </tbody>
            </table>
        )
    }
}