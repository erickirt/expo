import ExpoModulesCore

protocol CameraEvent {
  var onPictureSaved: EventDispatcher { get }
}

func takePictureForSimulator(
  _ appContext: AppContext?,
  _ event: CameraEvent,
  _ options: TakePictureOptions,
  _ promise: Promise
) throws {
  if options.fastMode {
    promise.resolve()
  }
  let result = try generatePictureForSimulator(appContext: appContext, options: options)

  if options.fastMode {
    event.onPictureSaved([
      "data": result,
      "id": options.id
    ])
  } else {
    promise.resolve(result)
  }
}

func takePictureRefForSimulator(
  _ appContext: AppContext?,
  _ event: CameraEvent,
  _ options: TakePictureOptions
) throws -> PictureRef {
  let generatedPhoto = ExpoCameraUtils.generatePhoto(of: CGSize(width: 200, height: 200))
  return PictureRef(generatedPhoto)
}

func generatePictureForSimulator(
  appContext: AppContext?,
  options: TakePictureOptions
) throws -> [String: Any?] {
  let path = FileSystemUtilities.generatePathInCache(
    appContext,
    in: "Camera",
    extension: ".jpg"
  )

  let generatedPhoto = ExpoCameraUtils.generatePhoto(of: CGSize(width: 200, height: 200))
  guard let photoData = generatedPhoto.jpegData(compressionQuality: options.quality) else {
    throw CameraInvalidPhotoData()
  }

  return [
    "uri": ExpoCameraUtils.write(data: photoData, to: path),
    "width": generatedPhoto.size.width,
    "height": generatedPhoto.size.height,
    "base64": options.base64 ? photoData.base64EncodedString() : nil
  ]
}
