class GitCommit extends React.Component {
    constructor(props) {
        super(props)
        this.state = { msg: "No Message" }
    }

    handleCommit(e) {
        this.props.onCommit(this.state.msg);
    }

    handleCancel(e) {
        this.props.onCancel();
    }

    render() {
        return (
            <div>
                <b> Commit </b> <br />
                <form onSubmit={ (e) => { e.preventDefault(); this.handleCommit(e) } }>
                    <input type="text" autoFocus onChange={ (e) => this.setState({ msg: e.target.value }) } name="commitmsg" placeholder="Commit Message" />
                    <a name="commit" onClick={ (e) => this.handleCommit(e) } className="button button-primary"> Commit! </a> &nbsp;
                    <a name="cancel" onClick={ (e) => this.handleCancel(e) } className="button button-primary button-red"> Cancel </a>
                </form>
            </div>
        );
    }
}

class GitStage extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            staged: [],
            unstaged: []
        }
    }

    handleSelect(event, action) {
        let value = event.target.value
        if (value != "") {
            if (action == "stage") {
                this.setState({
                    staged: this.state.staged.concat(this.state.unstaged.filter( file => file.name == value )),
                    unstaged: this.state.unstaged.filter ( file => file.name != value )
                });
            } else {
                this.setState({
                    unstaged: this.state.unstaged.concat(this.state.staged.filter( file => file.name == value )),
                    staged: this.state.staged.filter ( file => file.name != value )
                });
            }
        }
    }

    handleStage() {
        this.props.onStage(this.state);
    }

    handleCancel() {
        this.props.onCancel();
    }

    render() {
        return (
            <div className="row height-100">
                <div className="column">
                    <b> Unstaged </b>
                    <select multiple className="height-100" onChange={ (e) => this.handleSelect(e, "stage") }>
                        { this.state.unstaged.map((file) => <option> { file.name } </option>) }
                    </select>
                </div>
                <div className="column">
                    <b> Staged </b>
                    <select multiple className="height-100" onChange={ (e) => this.handleSelect(e, "unstage") }>
                        { this.state.staged.map((file) => <option> { file.name } </option>) }
                    </select>
                </div>
                <div className="column">
                    <a onClick={ () => this.handleStage() } className="button button-primary"> Stage </a> <br />
                    <a onClick={ () => this.handleCancel() } className="button button-primary button-red"> Cancel </a> <br />
                </div>
            </div>
        );
    }
}

class Git extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            status: {
                local: {
                    commit: { sha: "?", author: "?", msg: "?" },
                    branch: "?"
                },
                remote: {
                    commit: { sha: "?", author: "?", msg: "?" },
                    branch: "?"
                }
            },
            mode: "default"
        }
        this.websocket = new WebSocket('ws://' + window.location.host + "/ws/git")

        this.websocket.onmessage = (e) => {
            this.setState({ status: JSON.parse(e.data) })
        }
    }

    resetMode() {
        this.setState({ mode: "default" })
    }

    handleAction(action, extra) {
        if (action == "stage") {
            console.log("Stage");
            console.log(extra);
        } else if (action == "commit") {
            console.log("Commit");
            console.log(extra);
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
                    { this.state.status.local.commit.msg }
                </div>
                <div className="column column-66">
                { this.state.mode == "stage" ?
                    <GitStage
                        onCancel={ () => this.resetMode() }
                        onStage ={ (stageData) => { this.handleAction('stage', stageData); this.resetMode() } }
                    /> :
                        <div className="row">
                            <div className="column">
                                <b> Remote </b> <br />
                                { this.state.status.remote.commit.sha.substr(0,7) } on { this.state.status.remote.branch }<br />
                                { this.state.status.remote.commit.author }<br />
                                { this.state.status.remote.commit.msg }
                            </div>
                            <div className="column">
                                { this.state.mode == "commit" ? 
                                    <GitCommit 
                                        onCancel={ () => this.resetMode() } 
                                        onCommit={ (msg) => { this.handleAction('commit', msg); this.resetMode() } } 
                                    /> :
                                    <div>
                                        <a className="button button-primary" onClick={() => this.handleAction('update')}> Update </a> <br />
                                        <a className="button button-primary" onClick={() => this.handleAction('pull')}> Pull </a> &nbsp;
                                        <a className="button button-outline" onClick={() => this.handleAction('push')}> Push </a> <br />
                                        <a className="button button-primary" onClick={() => this.setState({ mode: "stage" }) }> Stage </a> &nbsp;
                                        <a className="button button-outline" onClick={() => this.setState({ mode: "commit" }) }> Commit </a> <br />
                                    </div>
                                }
                            </div>
                        </div>
                }
                </div>
            </div>
        );
    }
}