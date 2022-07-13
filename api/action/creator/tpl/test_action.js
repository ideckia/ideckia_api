const { IdeckiaAction } = require('.');

// put here the properties generated in the gen.readme.md file
const props = {};

const server = {
    log: {
        error: text => console.error(text),
        debug: text => console.debug(text),
        info: text => console.info(text)
    },
    dialog: {
        setOptions: (options) => console.log(options),
        notify: (title, _text) => console.log(title),
        info: (title, _text) => console.log(title),
        error: (title, _text) => console.log(title),
        question: (title, _text) => console.log(title),
        selectFile: (title, _isDirectory = false, _multiple = false, _fileFilter = null) => console.log(title),
        saveFile: (title, _saveName = null, _fileFilter = null) => console.log(title),
        entry: (title, _text, _placeholder = null) => console.log(title),
        password: (title, _text) => console.log(title),
        progress: (title, _text, _pulsate = false, _autoClose = true) => console.log(title),
        color: (title, _initialColor = "#FFFFFF", _palette = false) => console.log(title),
        calendar: (title, _text, _year = null, _month = null, _day = null, _dateFormat = null) => console.log(title),
        list: (title, _text, _columnHeader, _values, _multiple = false) => console.log(title)
    },
    updateClientState: state => console.log('New state sent to the client: ' + state)
};

const action = new IdeckiaAction();
action.setup(props, server);
action.execute({})
    .then(state => console.log('Resolved: ' + state))
    .catch(error => console.error('Rejected: ' + error));