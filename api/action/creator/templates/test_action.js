const { IdeckiaAction } = require('.');

const core = {
    log: {
        error: text => console.error(text),
        debug: text => console.debug(text),
        info: text => console.info(text)
    },
    dialog: {
        setDefaultOptions: (options) => console.log(options),
        notify: (title, _text) => console.log(title),
        info: (title, _text) => console.log(title),
        warning: (title, _text) => console.log(title),
        error: (title, _text) => console.log(title),
        question: (title, _text) => {
            console.log(title);
            return Promise.resolve(true);
        },
        selectFile: (title, _isDirectory = false, _openDirectory = "", _multiple = false, _fileFilter = null) => {
            console.log(title);
            return Promise.resolve(['file0path', 'file1path']);
        },
        saveFile: (title, _saveName = null, _openDirectory = "", _fileFilter = null) => {
            console.log(title);
            return Promise.resolve('filepath');
        },
        entry: (title, _text, _placeholder = null) => {
            console.log(title);
            return Promise.resolve('');
        },
        password: (title, _text, _userLabel = "username", _passwordLabel = "password", _username = false) => {
            console.log(title);
            return Promise.resolve(['username', 'password']);
        },
        progress: (title, _text, _pulsate = false, _autoClose = true) => {
            console.log(title);
            return {
                progress: (percentage) => console.log(`progress: ${percentage}`)
            };
        },
        color: (title, _label = "Select color", _initialColor = "#FFFFFF", _palette = false) => {
            console.log(title);
            return Promise.resolve({ red: 192, green: 192, blue: 192 });
        },
        calendar: (title, _text, _year = null, _month = null, _day = null, _dateFormat = null) => {
            console.log(title);
            return Promise.resolve(new Date().toString());
        },
        list: (title, _text, _columnHeader, _values, _multiple = false) => {
            console.log(title);
            return Promise.resolve(['item0', 'item1']);
        },
        custom: (path) => {
            console.log(path);
            return Promise.resolve(['item0', 'item1']);
        },
    },
    mediaPlayer: {
        play: (path) => {
            console.log(`Playing ${path} file.`);
            return 0;
        },
        pause: (id) => {
            console.log(`Pause ${id} media.`);
        },
        stop: (id) => {
            console.log(`Stop ${id} media.`);
        },
    },
    updateClientState: state => console.log('New state sent to the client: ' + state),
    data: {
        getCurrentLocale: () => 'en_UK',
        getContent: (path) => path + '_content',
        getJson: (path) => { path },
        getLocalizations: (path) => new Map([['en_UK', { id: 'name', text: 'text' }]]),
        getBytes: (path) => path + '_bytes',
        getBase64: (path) => path + '_base64',
    }
};

// put here the properties you want to test
const props = {};

const action = new IdeckiaAction();
action.setup(props, core);

const itemState = {
    text: 'State text',
    textSize: 15,
    textColor: '0x333333',
    icon: '',
    bgColor: '0x999999',
}
action.init(itemState)
    .then(responseState => console.log(responseState))
    .catch(error => console.error('init.rejected: ' + error));
action.execute(itemState)
    .then(responseState => console.log(responseState))
    .catch(error => console.error('execute.rejected: ' + error));