class Builders extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            status: {
                builders: []
            }
        }

        this.websocket = new WebSocket('ws://' + window.location.host + "/ws/builders")

        this.websocket.onmessage = (e) => {
            this.setState({ status: JSON.parse(e.data) })
        }
    }

    handleBuilder(builder, action) {
        this.websocket.send(JSON.stringify({ builder: builder.name, action: action }));
    }

    render() {
        return (
            <table>
                <tr>
                    <th> Name </th>
                    <th> Type </th>
                    <th> Actions </th>
                </tr>
                { this.state.status.builders.map((builder) =>
                    <tr>
                        <td> { builder.name } </td>
                        <td> { builder.type } </td>
                        <td>
                            <a className="button button-primary button-red" onClick={ () => this.handleBuilder(builder, "clean") }> Clean </a>&nbsp;
                            <a className="button button-primary" onClick={ () => this.handleBuilder(builder, "build") }> Build </a>
                        </td>
                    </tr>
                )}
            </table>
        );
    }
}