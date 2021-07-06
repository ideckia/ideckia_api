# Action for ideckia: ::name::

## Definition

TODO

## Properties

| Name | Type | Default | Description | Possible values |
| ----- |----- | ----- | ----- | ----- |
| propertyName | String | ["possible", "values", "for the property"] | Property description | "default_value" |

## Example in layout file

```json
{
    "state": {
        "text": "::name:: example",
        "bgColor": "00ff00",
        "action": {
            "name": "::lowerName::",
            "props": {
                "propertyName": "possible"
            }
        }
    }
}
```