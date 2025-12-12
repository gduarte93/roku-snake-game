'** 
'** Example: Edit a Label size and color with BrightScript
'**

function init()
    m.top.setFocus(true)
    m.myLabel = m.top.findNode("myLabel")

    'Set the font size
    m.myLabel.font.size=92

    'Set the color to light blue
    m.myLabel.color="0xFF0000"

    '**
    '** The full list of editable attributes can be located at:
    '** http://sdkdocs.roku.com/display/sdkdoc/Label#Label-Fields
    '**
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        m.myLabel = m.top.findNode("myLabel")

        if m.myLabel <> invalid
            m.myLabel.setFocus(true)
            print "valid Node"
        end if

        if (key = "up") then
            m.myLabel.font.size = m.myLabel.font.size + 5
        else if (key = "down") then
            m.myLabel.font.size = m.myLabel.font.size - 5
        end if
    end if
end function
