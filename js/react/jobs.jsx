class Jobs extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            status: {
                workers: [],
                queued: []
            }
        }

        this.websocket = new WebSocket('ws://' + window.location.host + "/ws/jobs")

        this.websocket.onmessage = (e) => {
            this.setState({ status: JSON.parse(e.data) })
        }
    }

    componentDidMount() {
        this.timerID = setInterval(
            () => this.tick(), 
            1000
        );
    }

    handleJob(job, action) {
        this.websocket.send(JSON.stringify({ job: job.hash, action: action }));
    }

    tick() {
        this.websocket.send("update")
    }

    render() {
        return (
            <div>
                <table>
                    <tr>
                        <th> Worker # </th>
                        <th> Job </th>
                    </tr>
                    { this.state.status.workers.map((worker) =>
                        <tr>
                            <td> { worker.id } </td>
                            <td> { worker.job } </td>
                        </tr>
                    )}
                </table>

                <table>
                    <tr>
                        <th> Queued Job </th>
                        <th> Cancelled? </th>
                        <th> Recurring? </th>
                        <th> Time </th>
                        <th> Action </th>
                    </tr>
                    <tbody>
                    { this.state.status.queued.map((job) =>
                        <tr>
                            <td> { job.name } </td>
                            <td> { job.cancelled ? "CANCELLED" : "-" } </td>
                            <td> { job.recurring } </td>
                            <td> { job.time } </td>
                            <td>
                                <a className="button button-primary" onClick={ () => this.handleJob(job, "immediate") }> Do Now </a>&nbsp;
                                <a className="button button-primary button-red" onClick={ () => this.handleJob(job, "cancel") }> Cancel </a>
                            </td>
                        </tr>
                    )}
                    </tbody>
                </table>
            </div>
        )
    }
}