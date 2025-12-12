' MyButton.brs
sub init()
  m.buttonLabel = m.top.FindNode("buttonLabel")
  m.buttonRect = m.top.FindNode("buttonRect")

  m.buttonLabel.text = m.top.buttonText
  m.buttonRect.color = m.top.buttonColor
  ' Add focus handling or other logic here
end sub

sub onTextChange()
    m.buttonLabel.text = m.top.buttonText
end sub

sub onColorChange()
    m.buttonRect.color = m.top.buttonColor
end sub