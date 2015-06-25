PreviewInline = require '../lib/preview-inline'

path = require 'path'


# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "PreviewInline", ->

  [editor, buffer, workspaceElement] = []

  beforeEach ->
    # directory = temp.mkdirSync()
    # atom.project.setPaths([directory])
    workspaceElement = atom.views.getView(atom.workspace)
    filePath = 'test.md'

    waitsForPromise ->
      atom.workspace.open(filePath).then (ed) -> editor = ed

    runs ->
      buffer = editor.getBuffer()

    waitsForPromise ->
      atom.packages.activatePackage('preview-inline')


  describe "PreviewInline::parseImageLocation", ->
    it "parses a url", ->
      url = "http://imgs.xkcd.com/comics/the_martian.png"

      expect(PreviewInline.parseImageLocation(url)).toEqual(url)

      # should work when the file basePath is provided
      expect(PreviewInline.parseImageLocation(url, __dirname)).toEqual(url)

    it "parses an absolute path", ->
      imgPath = path.join(__dirname, "test-image.jpg")
      expect(PreviewInline.parseImageLocation(imgPath)).toEqual(imgPath)

    it "parses a relative path, given a basePath", ->
      imgPath = "test-image.jpg"
      expect(PreviewInline.parseImageLocation(imgPath, __dirname))
        .toEqual(path.join(__dirname, "test-image.jpg"))


    it "throws an error for absolute path of a file that doesn't exist", ->
      imgPath =  path.join(__dirname, "non-image.jpg")
      expect(-> PreviewInline.parseImageLocation(imgPath))
        .toThrow(new Error("no image " + imgPath))

    it "throws an error for a relative path of a file that doesn't exist", ->
      imgPath = "non-image.jpg"
      expect(-> PreviewInline.parseImageLocation(imgPath, __dirname))
        .toThrow(new Error("no image " + imgPath))

    it "throws an error for a relative path if there is no basePath", ->
      imgPath = "test-image.jpg"
      expect(-> PreviewInline.parseImageLocation(imgPath))
        .toThrow(new Error("no image " + imgPath))

  describe "when the preview-inline:show image event is triggered", ->
    it "shows markdown image link under cursor (local)", ->
      expect(editor.getPath()).toContain 'test.md'
      editor.setCursorBufferPosition([5, 2])
      atom.commands.dispatch( workspaceElement, 'preview-inline:show')
      expect(workspaceElement.querySelector('.image-inline')).toExist()

      # TODO check image location is right

    it "only shows md image under cursor once", ->
      expect(editor.getPath()).toContain 'test.md'
      editor.setCursorBufferPosition([5, 5])
      expect(workspaceElement.querySelectorAll('.image-inline').length)
        .toEqual(0)

      atom.commands.dispatch workspaceElement, 'preview-inline:show'

      expect(workspaceElement.querySelectorAll('.image-inline').length)
        .toEqual(1)

      atom.commands.dispatch workspaceElement, 'preview-inline:show'

      expect(workspaceElement.querySelectorAll('.image-inline').length)
        .toEqual(1)
  describe "convert text into rendered math", ->
    it "returns the html element for the math", ->
      mathString = "x = \frac{1}{2}"
      rendered = PreviewInline.renderMath mathString
      expect(rendered).toExist()

  describe "when preview inline a latex formula event is triggered", ->
    it "correctly extracts the latex string from the cursor", ->
      #pass
    it "shows the math formula inline preview box", ->
      #pass
