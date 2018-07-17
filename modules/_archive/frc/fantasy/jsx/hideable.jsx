class Hideable extends React.Component {
    constructor(props) {
        super(props)
        this.state = { visible: true }
    }

    toggle() {
        this.setState({visible: !this.state.visible})
    }

    render() {
        return (
            <div>
                <h4>
                    <b>{this.props.name}</b> &nbsp;
                    <a className="button button-clear" onClick={(e) => { this.toggle() }}> 
                        { (this.state.visible ? "hide" : "show") }
                    </a>
                </h4>
                <div style={this.state.visible ? {} : { display: "none" } }>
                    {this.props.children}
                </div>
            </div>
        )
    }
}