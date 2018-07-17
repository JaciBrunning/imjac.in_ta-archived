class TitleView extends React.Component {
    constructor(props) {
        super(props)
        this.state = { name: "...", year: "...", refreshing: false, refresh_marked: false }
        frcevent.mount((data) => { this.setState({name: data.name, year: data.year}) })
        frcpoints.mount((data) => { this.refreshComplete() })
    }

    doRefresh() {
        if (!this.state.refreshing) {
            this.setState({refreshing: true, refresh_marked: false})
            frcpoints.refresh()
            frcevent.refresh()
        }
    }

    refreshComplete() {
        this.setState({refreshing: false, refresh_marked: true})
        setTimeout(() => { this.setState({refresh_marked: false}) }, 2000)
    }

    render() {
        return (
            <div>
                <h2> Fantasy FIRST - { this.state.year } { this.state.name } </h2>
                <h5> 
                    Presented by FIRST Updates Now || Site by Jaci
                    <a className={ ("button button-clear " + (this.state.refresh_marked ? "green" : "")) } 
                        onClick={ (e) => { this.doRefresh() } }> 
                            <i className={ 
                                ("fas " + 
                                (this.state.refresh_marked ? "fa-check" : "fa-sync-alt") +
                                (this.state.refreshing ? " fa-spin" : ""))
                                }> </i> Refresh
                    </a>
                </h5>
            </div>
        )
    }
}

function renderTitleView(id) {
    ReactDOM.render(<TitleView />, document.getElementById(id))
}