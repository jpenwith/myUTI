//
//  main.swift
//  myUTI
//
//  Created by me on 17/03/2017.
//  Copyright © 2017 me. All rights reserved.
//

import Foundation
import CoreServices

enum CommandError: Error {
    case invalidArgument(argumentName: String, argumentValue: String?)
}

func fileExtensionToUTI(fileExtension: String) -> String {
    let fileUTIUM = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)!
    let fileUTI = fileUTIUM.takeRetainedValue()

    return fileUTI as String
}

func fileMIMETypeToUTI(fileMIMEType: String) -> String {
    let fileUTIUM = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, fileMIMEType as CFString, nil)!
    let fileUTI = fileUTIUM.takeRetainedValue()

    return fileUTI as String
}

func fileUTIToExtension(fileUTI: String) -> String {
    let fileExtensionUM = UTTypeCopyPreferredTagWithClass(fileUTI as CFString, kUTTagClassFilenameExtension)!
    let fileExtension = fileExtensionUM.takeRetainedValue()
    
    return fileExtension as String
}

func fileUTIToMIMEType(fileUTI: String) -> String {
    let fileMIMETypeUM = UTTypeCopyPreferredTagWithClass(fileUTI as CFString, kUTTagClassMIMEType)!
    let fileMIMEType = fileMIMETypeUM.takeRetainedValue()

    return fileMIMEType as String
}

func processArguments(arguments: [String]) throws {
    if arguments.count == 1 {
        print("Get extension/UTI/mime-type for a given file, or convert between any extension/UTI/mime-type")
        print("")
        print("Usage:")
        print("\tmyUTI (file|extension|UTI|mime-type) (extension|UTI|mime-type) (path/to/file|string)")
        print("")

        exit(0)
    }

    let fromTypeName = arguments[1]

    switch fromTypeName {
        case "file":
            if arguments.count < 3 {
                throw CommandError.invalidArgument(argumentName: "toTypeName", argumentValue: nil)
            }
            if arguments.count < 4 {
                throw CommandError.invalidArgument(argumentName: "filePath", argumentValue: nil)
            }

            let toTypeName = arguments[2]
            let filePath = arguments[3]
            if !FileManager.default.fileExists(atPath: filePath) {
                throw CommandError.invalidArgument(argumentName: "filePath", argumentValue: filePath)
            }
            let fileURL = URL(fileURLWithPath: filePath)

            switch toTypeName {
                case "extension":
                    print(fileURL.pathExtension.lowercased())
                case "UTI":
                    let fileUTI = fileExtensionToUTI(fileExtension: fileURL.pathExtension)

                    print(fileUTI)
                case "mime-type":
                    let fileUTI = fileExtensionToUTI(fileExtension: fileURL.pathExtension)
                    let fileMIMEType = fileUTIToMIMEType(fileUTI: fileUTI)

                    print(fileMIMEType)
                default:
                    throw CommandError.invalidArgument(argumentName: "toTypeName", argumentValue: toTypeName)
            }
        case "extension":
            if arguments.count < 3 {
                throw CommandError.invalidArgument(argumentName: "toTypeName", argumentValue: nil)
            }
            if arguments.count < 4 {
                throw CommandError.invalidArgument(argumentName: "string", argumentValue: nil)
            }

            let toTypeName = arguments[2]
            let string = arguments[3]

            switch toTypeName {
                case "UTI":
                    print(fileExtensionToUTI(fileExtension: string))
                case "mime-type":
                    print(fileUTIToMIMEType(fileUTI: fileExtensionToUTI(fileExtension: string)))
                default:
                    throw CommandError.invalidArgument(argumentName: "to", argumentValue: toTypeName)
            }
        case "UTI":
            if arguments.count < 3 {
                throw CommandError.invalidArgument(argumentName: "toTypeName", argumentValue: nil)
            }
            if arguments.count < 4 {
                throw CommandError.invalidArgument(argumentName: "string", argumentValue: nil)
            }

            let toTypeName = arguments[2]
            let string = arguments[3]

            switch toTypeName {
                case "extension":
                    print(fileUTIToExtension(fileUTI: string))
                case "mime-type":
                    print(fileUTIToMIMEType(fileUTI: string))
                default:
                    throw CommandError.invalidArgument(argumentName: "to", argumentValue: toTypeName)
            }
        case "mime-type":
            if arguments.count < 3 {
                throw CommandError.invalidArgument(argumentName: "toTypeName", argumentValue: nil)
            }
            if arguments.count < 4 {
                throw CommandError.invalidArgument(argumentName: "string", argumentValue: nil)
            }

            let toTypeName = arguments[2]
            let string = arguments[3]

            switch toTypeName {
                case "extension":
                    print(fileUTIToExtension(fileUTI: fileMIMETypeToUTI(fileMIMEType: string)))
                case "UTI":
                    print(fileMIMETypeToUTI(fileMIMEType: string))
                default:
                    throw CommandError.invalidArgument(argumentName: "to", argumentValue: toTypeName)
            }
        default:
            throw CommandError.invalidArgument(argumentName: "from", argumentValue: fromTypeName)
    }
}

do {
    try processArguments(arguments: CommandLine.arguments)
}
catch CommandError.invalidArgument(let argumentName, let argumentValue){
    if argumentValue == nil {
        print("Missing argument: \(argumentName)")
    }
    else{
        print("Invalid argument: \(argumentName): \"\(argumentValue!)\"")
    }
}
