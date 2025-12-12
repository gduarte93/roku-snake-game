sub init()
    ' m.top.setFocus(true)
    m.head = m.top.findNode("head")
    m.head.setFocus(true)

    print "init MainScene"
end sub

' function onKeyEvent(key as String, press as Boolean) as Boolean
'     print "MainScene Key"
' end function

' sub Main()
'     deviceInfo = CreateObject("roDeviceInfo")
'     displaySize = deviceInfo.GetDisplaySize()

'     print m.head.translation[0]
'     print displaySize?.w
'     print displaySize?.h
'     print m.head.width

    ' while m.head.translation[0] < 1000 ' displaySize?.w
    '     newX = m.head.translation[0] + m.head.width

    '     if newX > displaySize?.w
    '         newX = displaySize?.w
    '     end if

    '     m.head.translation = [newX, m.head.translation[1]]
    ' end while
' end sub