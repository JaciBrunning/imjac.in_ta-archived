class PicksFetcher {
    constructor() {
        this.entries = {}
        this.callbacks = []
    }

    refresh() {
        fetch("entries.json")
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

let picks = new PicksFetcher()

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