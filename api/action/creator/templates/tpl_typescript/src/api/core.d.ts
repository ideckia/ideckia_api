import { Dialog } from "./dialog";
import { LocalizedTexts } from "./data";
import { MediaPlayer } from "./mediaPlayer";

export type IdeckiaCore = {
    data: {
        getBase64: (path: string) => string,
        getBytes: (path: string) => any,
        getContent: (path: string) => string,
        getCurrentLocale: () => string,
        getJson: (path: string) => any,
        getLocalizations: (path: string) => LocalizedTexts
    },
    dialog: Dialog,
    log: {
        debug: (v: any) => void,
        error: (v: any) => void,
        info: (v: any) => void
    },
    mediaPlayer: MediaPlayer,
    updateClientState: (props: ItemState) => void
}

export type ItemState = {
    bgColor?: null | string,
    icon?: null | string,
    text?: null | string,
    textColor?: null | string,
    textPosition?: null | string,
    textSize?: null | number,
    extraData?: null | {
        data: any,
        fromAction?: null | string
    }
}


export enum TextPosition {
    top = 'top',
    center = 'center',
    bottom = 'bottom',
}

export type ActionOutcome = {
    directory?: null | DynamicDir,
    state?: null | ItemState
}

export type DynamicDir = {
    bgColor?: null | string,
    columns?: null | number,
    items: DynamicDirItem[],
    rows?: null | number
}

export type DynamicDirItemAction = {
    name: string,
    props?: null | any,
    status?: null | ActionStatus
}

export type DynamicDirItem = {
    actions?: null | DynamicDirItemAction[],
    bgColor?: null | string,
    extraData?: null | {
        data: any,
        fromAction?: null | string
    },
    icon?: null | string,
    text?: null | string,
    textColor?: null | string,
    textPosition?: null | string,
    textSize?: null | number,
    toDir?: null | string
}

export const enum ActionStatusCode {
    unknown = 'unknown',
    error = 'error',
    ok = 'ok'
}

export type ActionStatus = {
    code: ActionStatusCode,
    message?: null | string
}

export type PropDescriptor = {
    defaultValue: string,
    description?: null | string,
    isShared?: null | boolean,
    name: string,
    possibleValues?: null | string[],
    sharedName?: null | string,
    type: string,
    value?: null | string
}

export type PresetAction = {
    name: string,
    props: any
}

export type ActionDescriptor = {
    description?: null | string,
    id?: null | number,
    name: string,
    presets?: null | PresetAction[],
    props?: null | PropDescriptor[]
}