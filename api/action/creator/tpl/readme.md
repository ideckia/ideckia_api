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
    "text": "::name:: example",
    "bgColor": "00ff00",
        "actions": [
            {
                "name": "::lowerName::",
                "props": {
                    "propertyName": "possible"
            }
        }
    ]
}
```