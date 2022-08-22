# Action for [ideckia](https://ideckia.github.io/): ::name::

## Description

::description::

## Properties

| Name | Type | Description | Shared | Default | Possible values |
| ----- |----- | ----- | ----- | ----- | ----- |
| propertyName | String | Property description | false | "default_value" | ["possible", "values", "for the property"] |

## On single click

TODO

## On long press

TODO

## Test the action

There is a script called `test_action.js` to test the new action. Set the `props` variable in the script with the properties you want and run this command:

```
node test_action.js
```

## Example in layout file

```json
{
    "text": "::name:: example",
    "bgColor": "00ff00",
    "actions": [
        {
            "name": "::name::",
            "props": {
                "propertyName": "possible"
            }
        }
    ]
}
```
