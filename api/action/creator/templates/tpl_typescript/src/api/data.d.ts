export class Data {
    static getContent(path: string): null | string
    static getJson(path: string): null | any
    static getLocalizations(path: string): LocalizedTexts
    static getBytes(path: string): null | any
    static getBase64(path: string): null | string
}

export type LocString = {
    comment?: null | string,
    id: string,
    text: string
}

export type LocalesMap = Map<string, LocString[]>

export class LocalizedTexts {
    private constructor(v?: null | LocalesMap)
    protected localesMap: LocalesMap
    tr(localeId: string, stringId: string, args?: null | any[]): string
    exists(localeId: string): boolean
    get(localeId: string): null | LocString[]
}