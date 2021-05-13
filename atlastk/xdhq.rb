=begin
MIT License

Copyright (c) 2018 Claude SIMON (https://q37.info/s/rmnmqd49)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
=end

module XDHq
	require 'XDHqFAAS'
	require 'uri'

	$dir = ""

	$VOID=XDHqSHRD::VOID
	$STRING=XDHqSHRD::STRING
	$STRINGS=XDHqSHRD::STRINGS
  class << self
    def split(keysAndValues)
      keysAndValues.reduce([[],[]]) do |keys_values, knv|
        [
          keys_values[0].push(knv[0]), 
          keys_values[1].push(knv[1])
        ]
      end
    end

    def unsplit(keys, values)
      Hash[keys.zip(values)]
    end

    def getAssetPath(dir)
      XDHqSHRD.isDev?() ? File.join("/home/csimon/epeios/tools/xdhq/examples/common/", dir)
        : File.join(Dir.pwd,dir)
    end

    def getAssetFilename(path, dir)
      File.join(getAssetPath(dir), path)
    end

    def readAsset(path, dir = "")
      File.read(getAssetFilename(path,dir), encoding: 'UTF-8')
    end
    
    def launch(callback,userCallback,callbacks,headContent, dir)
      $dir = dir
      XDHqFAAS.launch(callback, userCallback, callbacks, headContent)
    end

    def broadcastAction(action,id)
      XDHqFAAS.broadcastAction(action,id)
    end
  end

	class DOM
		def initialize(id)
			@dom = XDHqFAAS::DOM.new(id)
		end

		private def unsplit(*args)
			return XDHq.unsplit(*args)
		end

		private def split(*args)
			return XDHq.split(*args)
		end

		private def call(command, type, *args)
			return @dom.call(command,type,*args)
		end

		def getAction
			return @dom.getAction()
		end

		def isQuitting?
			return @dom.isQuitting?
		end

		private def execute(type, script)
			return call("Execute_1" ,type, script)
		end

		def executeVoid(script)
			execute($VOID, script)
		end
	
		def executeString(script)
			return execute($STRING, script)
		end
	
		def executeStrings(script)
			return execute($STRINGS, script)
		end

		def flush(id)
			call("Flush_1", $STRING, id)
		end
	
		def alert(message)
			call( "Alert_1", $STRING, message)
		# For the return value being 'STRING' instead of 'VOID',
		# see the 'alert' primitive in 'XDHqXDH'.
		end

		def confirm?(message)
			return call("Confirm_1", $STRING, message) == "true"
		end

		private def handleLayout(variant, id, xml, xslFilename = "")
			call("HandleLayout_1", $VOID, variant, id, if xml.is_a?( String ) then xml else xml.toString() end, xslFilename)
		end

		def prependLayout(id, html)	# Deprecated!
			handleLayout("Prepend", id, html)
		end

		def setLayout(id, html)	# Deprecated!
			handleLayout("Set", id, html)
		end

		def appendLayout(id, html)	# Deprecated!
			handleLayout("Append", id, html)
		end

		private def handleLayoutXSL(variant, id, xml, xsl)
			xslURL = xsl

			if true	# Testing if 'SlfH' or 'FaaS' mode when available.
				xslURL = "data:text/xml;charset=utf-8," + URI::encode(XDHq::readAsset( xsl, $dir ))
			end

			handleLayout(variant, id, xml, xslURL )
		end

		def prependLayoutXSL(id, xml, xsl)	# Deprecated!
			handleLayoutXSL("Prepend", id, xml, xsl)
		end

		def setLayoutXSL(id, xml, xsl)	# Deprecated!
			handleLayoutXSL("Set", id, xml, xsl)
		end

		def appendLayoutXSL(id, xml, xsl)	# Deprecated!
			handleLayoutXSL("Append", id, xml, xsl)
		end

		private def layout(variant, id, xml, xsl)
			if !xsl.empty?
				xsl = "data:text/xml;charset=utf-8," + URI::encode(XDHq::readAsset( xsl, $dir ))
			end

			call("HandleLayout_1", $VOID, variant, id, if xml.is_a?( String ) then xml else xml.toString() end, xsl)
		end
		
		def before(id, xml, xsl="")
			layout("beforebegin", id, xml, xsl)
		end
	
		def begin(id, xml, xsl="")
			layout("afterbegin", id, xml, xsl)
		end
	
		def inner(id, xml, xsl="")
			layout("inner", id, xml, xsl)
		end
	
		def end(id, xml, xsl="")
			layout("beforeend", id, xml, xsl)
		end
	
		def after(id, xml, xsl="")
			layout("afterend", id, xml, xsl)
		end
	
		def getContents(ids) # Deprecated!
			return unsplit(ids, call("GetContents_1", $STRINGS, ids))
		end

		def getContent(id) # Deprecated!
			return getContents([id])[id]
		end

		def setContents(idsAndContents) # Deprecated!
			ids, contents = split(idsAndContents)
			call("SetContents_1", $VOID, ids, contents)
		end

		def setContent(id, content) # Deprecated!
			setContents({id => content})
		end

###
		def getValues(ids)
			return unsplit(ids, call("GetValues_1", $STRINGS, ids))
		end

		def getValue(id)
			return getValues([id])[id]
		end

		def setValues(idsAndValues)
			ids, values = split(idsAndValues)
			call("SetValues_1", $VOID, ids, values)
		end

		def setValue(id, value)
			setValues({id => value})
		end
###

###
		def getMarks(ids)
			return unsplit(ids, call("GetMarks_1", $STRINGS, ids))
		end

		def getMark(id)
			return getMarks([id])[id]
		end

		def setMarks(idsAndMarks)
			ids, marks = split(idsAndMarks)
			call("SetMarks_1", $VOID, ids, marks)
		end

		def setMark(id, mark)
			setMarks({id => mark})
		end
###

# =begin	
# 		def createElement(name, id = "" )
# 			return call( "CreateElement_1", $STRING, 2, name, id, 0 )
# 		end
	
# 		def insertChild(child, id)
# 			call( "InsertChild_1", $VOID, 2, child, id, 0 )
# 		end
# =end	

		private def handleClasses(variant, idsAndClasses)
			ids, classes = split(idsAndClasses)
	
			call("HandleClasses_1", $VOID, variant, ids, classes)
		end
	
		def addClasses(idsAndClasses)
			handleClasses("Add", idsAndClasses)
		end
	
		def removeClasses(idsAndClasses)
			handleClasses("Remove", idsAndClasses)
		end
	
		def toggleClasses(idsAndClasses)
			handleClasses("Toggle", idsAndClasses)
		end
	
		def addClass(id, clas)
			addClasses({id => clas})
		end
	
		def removeClass(id, clas )
			removeClasses({id => clas})
		end
	
		def toggleClass(id, clas)
			toggleClasses({id => clas})
		end
	
		def enableElements(ids)
			call("EnableElements_1", $VOID, ids)
		end
	
		def enableElement(id)
			enableElements([id])
		end
	
		def disableElements(ids)
			call("DisableElements_1", $VOID, ids)
		end
	
		def disableElement(id)
			disableElements([id])
		end
	
		def setAttribute(id, name, value )
			call("SetAttribute_1", $VOID, id, name, value )
		end
	
		def getAttribute(id, name)
			return call("GetAttribute_1", $STRING, id, name )
		end
	
		def removeAttribute(id, name )
			call("RemoveAttribute_1", $VOID, id, name )
		end
	
		def setProperty(id, name, value )
			call("SetProperty_1", $VOID, id, name, value )
		end
	
		def getProperty(id, name )
			return call("GetProperty_1", _STRING, id, name )
		end

		def focus(id)
			call("Focus_1", $VOID, id )
		end

		def parent(id)
			return call("Parent_1", $STRING, id)
		end

		def firstChild(id)
			return call("FirstChild_1", $STRING, id)
		end

		def lastChild(id)
			return call("LastChild_1", $STRING, id)
		end

		def previousSibling(id)
			return call("PreviousSibling_1", $STRING, id)
		end

		def nextSibling(id)
			return call("NextSibling_1", $STRING, id)
		end

		def scrollTo(id)
			call("ScrollTo_1", $VOID, id)
		end
	end
end
