class GitCommit extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            staged: [],
            unstaged: props.files,
            msg: "No Message"
        }
    }

    handleSelect(select_file, action) {
        if (action == "stage") {
            this.setState({
                staged: this.state.staged.concat([select_file]),
                unstaged: this.state.unstaged.filter ( file => file != select_file )
            });
        } else {
            this.setState({
                unstaged: this.state.unstaged.concat([select_file]),
                staged: this.state.staged.filter ( file => file != select_file )
            });
        }
    }

    handleCommit(e) {
        this.props.onCommit(this.state);
    }

    handleCancel(e) {
        this.props.onCancel();
    }

    renderFileInList(file, action) {
        let style = {color: (file.status == "M" ? "blue" : file.status == "D" ? "red" : "green")};
        return ( <a className="smalltext" style={ style } onClick={ e => this.handleSelect(file, action) }> { file.name } </a> );
    }

    render() {
        return (
            <div className="row height-100">
                <div className="column">
                    <b> Unstaged </b>
                    <table>
                        { this.state.unstaged.map((file) => <tr> { this.renderFileInList(file, "stage") } </tr>) }
                    </table>
                </div>
                <div className="column">
                    <b> Staged </b>
                    <table>
                        { this.state.staged.map((file) => <tr> { this.renderFileInList(file, "unstage") } </tr>) }
                    </table>
                </div>
                <div className="column">
                    <b> Commit </b>
                    <form onSubmit={ (e) => { e.preventDefault(); this.handleCommit(e) } }>
                        <input type="text" autoFocus onChange={ (e) => this.setState({ msg: e.target.value }) } name="commitmsg" placeholder="Commit Message" />
                        <a name="commit" onClick={ (e) => this.handleCommit(e) } className="button button-primary"> Commit! </a> &nbsp;
                        <a name="cancel" onClick={ (e) => this.handleCancel(e) } className="button button-primary button-red"> Cancel </a>
                    </form>
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
                branches: [],
                head: "?",
                changed_files: []
            },
            mode: "default"
        }
        this.websocket = new WebSocket('ws://' + window.location.host + "/ws/git")

        this.websocket.onmessage = (e) => {
            this.setState({ status: JSON.parse(e.data) });
        }
    }

    resetMode() {
        this.setState({ mode: "default" });
    }

    handleAction(action, extra) {
        if (action == "commit") {
            if (extra.staged.length > 0) {
                this.websocket.send(JSON.stringify({ action: "commit", msg: extra.msg, staged: extra.staged }));
                this.websocket.send(JSON.stringify({ action: "update" }));
            }
        } else {
            this.websocket.send(JSON.stringify({ action: action }));
        }
    }

    render() {
        let targetBranch = this.state.status.branches.find( b => b.branch == this.state.status.head );
        return (
            this.state.mode == "commit" ? 
                <GitCommit 
                    files={ this.state.status.changed_files }
                    onCancel={ () => this.resetMode() } 
                    onCommit={ (commitState) => { this.handleAction('commit', commitState); this.resetMode() } } 
                /> :
                <div className="row">
                    <div className="column">
                        <b> Local </b> <br />
                        { targetBranch == undefined ? 
                            <i> No Data </i> :
                            <div>
                                { targetBranch.commit.sha.substr(0,7) } on { targetBranch.name }<br />
                                { targetBranch.commit.author } <br />
                                { targetBranch.commit.message } <br />
                                { this.state.status.changed_files.length > 0 ? <a style={{color: "red"}}>Uncommited Changes!</a> : "Local branch clean" }
                            </div>
                        }
                    </div>
                    <div className="column">
                        <b> Actions </b><br />
                        <a className="button button-primary" onClick={() => this.handleAction('update')}> Update </a> <br />
                        <a className="button button-outline" onClick={() => this.setState({ mode: "commit" }) }> Commit </a> <br />
                    </div>
                </div>
        );
    }
}