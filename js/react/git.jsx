class Git extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            status: { 
                changed: "?", 
                untracked: "?",
                local: {
                    commit: { sha: "?", author: "?", msg: "?" },
                    branch: "?"
                },
                remote: {
                    commit: { sha: "?", author: "?", msg: "?" },
                    branch: "?"
                }
            }
        }
        this.websocket = new WebSocket('ws://' + window.location.host + "/ws/git")

        this.websocket.onmessage = (e) => {
            this.setState({ status: JSON.parse(e.data) })
        }
    }

    handleAction(action) {
        if (action == "stage") {

        } else if (action == "commit") {

        } else {
            this.websocket.send(action);
        }
    }

    render() {
        return (
            <div className="row">
                <div className="column">
                    <b> Local </b> <br />
                    { this.state.status.local.commit.sha.substr(0,7) } on { this.state.status.local.branch }<br />
                    { this.state.status.local.commit.author }<br />
                    { this.state.status.local.commit.msg }<br /> <br />
                    { this.state.status.changed } Tracked Changes <br />
                    { this.state.status.untracked } Untracked Changes <br />
                </div>
                <div className="column">
                    <b> Remote </b> <br />
                    { this.state.status.remote.commit.sha.substr(0,7) } on { this.state.status.remote.branch }<br />
                    { this.state.status.remote.commit.author }<br />
                    { this.state.status.remote.commit.msg }<br /> <br />
                </div>
                <div className="column">
                    <a className="button button-primary" onClick={() => this.handleAction('update')}> Update </a> <br />
                    <a className="button button-primary" onClick={() => this.handleAction('pull')}> Pull </a> <br />
                    <br />
                    <a className="button button-outline" onClick={() => this.handleAction('stage')}> Stage </a> <br />
                    <a className="button button-outline" onClick={() => this.handleAction('commit')}> Commit </a> <br />
                    <a className="button button-outline" onClick={() => this.handleAction('push')}> Push </a> <br />
                </div>
            </div>
        );
    }
}