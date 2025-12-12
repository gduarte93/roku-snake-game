' UIButton.brs
sub init()
    print "UIBlock init"

    m.loseLabel = m.top.findNode("loseLabel")
    m.loseLabel.font.size = 120

    m.block = m.top.findNode("block")
    m.direction = invalid
    m.childBlockList = []
    m.oldHeadTranslation = invalid
    m.alive = true

    m.timesMoved = 0

    deviceInfo = CreateObject("roDeviceInfo")
    m.displaySize = deviceInfo.GetDisplaySize()

    if m.block <> invalid 
        m.block.color = m.top.backgroundColor
        m.block.translation = [0, 0]

        if m.displaySize <> invalid then
            m.maxWidth = Int(m.displaySize.w / m.block.width) * m.block.width
            m.maxHeight = Int(m.displaySize.h / m.block.height) * m.block.height
        end if

        m.fruitPosition = getEmptyLocationOnScreen()
        addBlock(true)

        m.timer = createObject("roSGNode", "Timer")
        m.timer.duration = 0.4
        m.timer.control = "start"
        m.timer.repeat = true
        m.timer.ObserveField("fire", "animateBlock")
    end if
end sub

sub animateBlock()
    if m.alive = false then
        ' To ensure lose label appears highest z-index
        parent = m.loseLabel.getParent()
        parent.removeChild(m.loseLabel)
        parent.appendChild(m.loseLabel)

        m.timer.control = "stop"
        m.loseLabel.visible = true
    else
        if m.direction <> invalid then
            moveBlock(m.direction)
        end if
    end if
end sub

sub onBackgroundColorChange()
    m.block.color = m.top.backgroundColor
end sub

function getRandomLocationOnScreen() as Object
    return [Int(Rnd(m.maxWidth - m.block.width + 1) / m.block.width) * m.block.width, Int(Rnd(m.maxHeight - m.block.height + 1) / m.block.height) * m.block.height]
end function

function getEmptyLocationOnScreen() as object
    loc = getRandomLocationOnScreen()

    while NOT isEmptyPosition(loc)
        loc = getRandomLocationOnScreen()

        ' TODO: detect when not able to fit anoter fruit so we don't get stuck in an infinite loop
    end while

    return loc
end function

function moveBlock(direction as String, blockToMove = m.block) as Boolean
    if blockToMove <> invalid AND m.displaySize <> invalid then
        m.oldHeadTranslation = blockToMove.translation
        newX = invalid
        newY = invalid
        if (direction = "right") then
            newX = blockToMove.translation[0] + blockToMove.width
        else if (direction = "left") then
            newX = blockToMove.translation[0] - blockToMove.width
        else if (direction = "up") then
            newY = blockToMove.translation[1] - blockToMove.width
        else if (direction = "down") then
            newY = blockToMove.translation[1] + blockToMove.width
        end if

        if newX <> invalid
            if newX < 0 then
                newX = 0
                m.alive = false
            end if

            if blockToMove.translation[0] + blockToMove.width > m.displaySize.w then
                m.alive = false
            end if

            ' if newX >= m.displaySize.w - blockToMove.width then
            '     newX = m.displaySize.w - blockToMove.width
            '     alive = false
            ' end if

            if (m.alive AND validMove([newX, blockToMove.translation[1]])) then
                blockToMove.translation = [newX, blockToMove.translation[1]]
            else
                m.alive = false
            endif

        end if

        if newY <> invalid
            if newY < 0 then
                newY = 0
                m.alive = false
            end if

            if blockToMove.translation[1] + blockToMove.height > m.displaySize.h then
                m.alive = false
            end if

            ' if newY >= m.displaySize.h - blockToMove.width then
            '     newY = m.displaySize.h - blockToMove.width
            '     alive = false
            ' end if

            if (m.alive AND validMove([blockToMove.translation[0], newY])) then
                blockToMove.translation = [blockToMove.translation[0], newY]
            else
                m.alive = false
            endif
        end if

        if blockToMove.translation[0] = m.fruitPosition[0] AND blockToMove.translation[1] = m.fruitPosition[1] then
            m.fruitBlock.visible = false
            addBlock()
            updateFruit()
        end if
    end if

    if m.alive then
        m.timesMoved += 1

        updateChildBlockTranslations()
    end if

    return m.alive
end function

sub updateFruit()
    if m.fruitBlock <> invalid then
        m.fruitPosition = getEmptyLocationOnScreen()
        m.fruitBlock.translation = m.fruitPosition
        m.fruitBlock.visible = true
    end if
end sub

function validMove(position as Object) as boolean
    for each block in m.childBlockList
        childPosition = block.node?.translation

        if childPosition[0] = position[0] AND childPosition[1] = position[1] then return false
    end for

    return true
end function

function isEmptyPosition(position as Object) as boolean
    if m.block.translation[0] = position[0] AND m.block.translation[1] = position[1] then return false

    for each block in m.childBlockList
        childPosition = block.node?.translation

        if childPosition[0] = position[0] AND childPosition[1] = position[1] then return false
    end for

    return true
end function

sub updateChildBlockTranslations()
    for i = m.childBlockList.Count() - 1 to 0 Step -1
        if i = 0 then
            m.childBlockList[i].node.translation = m.oldHeadTranslation
        else
            m.childBlockList[i].node.translation = m.childBlockList[i - 1].node.translation
        end if
    end for
end sub

sub addBlock(isFruit = false)
    ' PADDING = 5
    newBlock = CreateObject("roSGNode", "Rectangle")
    newBlock.width = m.block.width
    newBlock.height = m.block.height
    newBlock.color = m.block.color

    if isFruit then
        newBlock.color = "0xFF0000"
        newBlock.translation = m.fruitPosition

        m.fruitBlock = newBlock
    else
        lastChildBlock = m.childBlockList.Peek()
        leadBlock = invalid
        if lastChildBlock <> invalid
            leadBlock = lastChildBlock.node
            direction = lastChildBlock.direction
        else
            leadBlock = m.block
            direction = m.direction
        end if

        if (m.direction = "right") then
            newBlock.translation = [leadBlock.translation[0] - m.block.width, leadBlock.translation[1]]
        else if (m.direction = "left") then
            newBlock.translation = [leadBlock.translation[0] + m.block.width, leadBlock.translation[1]]
        else if (m.direction = "up") then
            newBlock.translation = [leadBlock.translation[0], leadBlock.translation[1] + m.block.height]
        else if (m.direction = "down") then
            newBlock.translation = [leadBlock.translation[0], leadBlock.translation[1] - m.block.height]
        end if


        m.childBlockList.push({ node: newBlock, direction: direction })
    end if

    m.top.appendChild(newBlock)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        if m.block <> invalid AND m.displaySize <> invalid then
            newX = invalid
            newY = invalid
            ' TODO: fix quick change direction can cause head to run into self
            '   e.g. right -> down -> left can 
            if (key = "right" AND m.direction <> "left") then
                m.direction = key
            else if (key = "left" AND m.direction <> "right") then
                m.direction = key
            else if (key = "up" AND m.direction <> "down") then
                m.direction = key
            else if (key = "down" AND m.direction <> "up") then
                m.direction = key
            end if
        end if
    end if
end function