class PicksFetcher {
    constructor(url) {
        this.url = url
        this.entries = {}
        this.callbacks = []
    }

    refresh() {
        fetch(this.url)
            .then(response => response.json())
            .then(data => this.onDataAvailable(data))
    }

    onDataAvailable(data) {
        this.entries = data
        this.callbacks.forEach((cb) => {cb(data)})
    }

    mount(callback) {
        this.callbacks.push(callback)
        this.refresh();
    }
}

let picks = new PicksFetcher("picks.json")
let host_picks = new PicksFetcher("hosts.json")

class EventInfoFetcher {
    constructor() {
        this.data = {}
        this.callbacks = []
    }

    refresh() {
        fetch("event.json")
            .then(response => response.json())
            .then(data => this.onDataAvailable(data))
    }

    onDataAvailable(data) {
        this.data = data
        this.callbacks.forEach((cb) => {cb(this.data)})
    }

    mount(callback) {
        this.callbacks.push(callback)
        this.refresh();
    }
}

let frcevent = new EventInfoFetcher()

class PointsFetcher {
    constructor() {
        this.points = {}
        this.callbacks = []
    }

    refresh() {
        fetch("points.json")
            .then(response => response.json())
            .then(data => this.onDataAvailable(data))
    }

    onDataAvailable(data) {
        this.points = data
        this.callbacks.forEach((cb) => {cb(this.points)})
    }

    mount(callback) {
        this.callbacks.push(callback)
        this.refresh();
    }
}

let frcpoints = new PointsFetcher()

class RenderHelper {
    renderTeam(team) {
        let isHost = team.tag == "host"
        let isDQ = team.spent > 100
    
        return <span>
            {
                isDQ ? <i className="fas fa-exclamation-triangle"> </i> : 
                    isHost ? <i className="fas fa-microphone"> </i> : ""
            } &nbsp;
            {team.team + (isDQ ? " (OVER BUDGET)" : "")}
        </span>
    }

    teamClass(team) {
        return (team.spent > 100) ? "dq" : (team.tag == "host" ? "host" : "")
    }
}

let renderHelper = new RenderHelper()