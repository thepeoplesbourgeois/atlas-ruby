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

$threads = []

module Atlas
  require 'XDHq'
  require 'XDHqXML'

  class << self
    def l
      caller_infos = caller.first.split(":")
      puts "#{caller_infos[0]}:#{caller_infos[1]}"  
    end

    def createXML(rootTag)
      XDHqXML::XML.new(rootTag)
    end

    def createHTML(rootTag = "")
      createXML(rootTag)
    end

    def call_(callback, userObject, dom, id, action)
      {
        0 => -> { callback.call() },
        1 => -> { callback.call(userObject) },
        2 => -> { callback.call(userObject, dom) },
        3 => -> { callback.call(userObject, dom, id) },
        4 => -> { callback.call(userObject, dom, id, action }  
      }[callback.arity].()
    end

    def thread(userObject, dom, callbacks)
      until dom.isQuitting?
        action, id = dom.getAction()
        call_(callbacks[action], userObject, dom, id, action)
      end
    end

    def cb(userObject, callbacks, instance)
      Thread.new(
        userObject,
        XDHq::DOM.new(instance),
        callbacks
      ) { |userObject, dom, callbacks| thread(userObject, dom, callbacks) }
    end

    def launch(callbacks,callback = (-> () {}), headContent = "", dir = "")
      XDHq.launch(
        -> (userObject, callbacks, id) { cb(userObject, callbacks, id) }, 
        callback, 
        callbacks, 
        headContent, 
        dir
      )
    end

    def broadcastAction(action, id = "")
      XDHq.broadcastAction(action, id)
    end

    def readAsset(path, dir = "")
      XDHq.readAsset(path, dir)
    end
  end
end
