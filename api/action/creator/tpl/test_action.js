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
        info: text => console.info(text),
        error: text => console.error(text),
        question: text => console.info(text),
        entry: text => console.info(text),
        fileselect: text => console.info(text)
    },
    updateClientState: state => console.log('New state sent to the client: ' + state)
};

const action = new IdeckiaAction();
action.setup(props, server);
action.execute({})
    .then(state => console.log('Resolved: ' + state))
    .catch(error => console.error('Rejected: ' + error));