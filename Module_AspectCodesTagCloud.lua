local p = {}

function p.show()
  if not mw.smw then
    return "mw.smw module not found"
  end

  local conferenceContributionsQuery = mw.smw.getQueryResult(" \
    [[HasConferenceContributionAspectCode::+]] \
    |?HasConferenceContributionAspectCode \
    |?HasConferenceContributionType \
    |?HasConferenceContributionStatus \
    |?HasEntityTitle \
    |?HasEntityBlurb \
  ")
  if conferenceContributionsQuery == nil then
    return "(no values)"
  end

  if type( conferenceContributionsQuery ) == "table" then

    local conferenceContributions = {}
    for k,v in pairs( conferenceContributionsQuery.results ) do
      table.insert(conferenceContributions, {
        conferenceContribution = v.fulltext,
        properties = v.printouts
      } )
    end

    -- Sort by AspectCode
    conferenceContributionsByAspectCode = {}
    for k,v in pairs(conferenceContributions) do
      page = mw.title.new(v.conferenceContribution)
      if tableHasKey(conferenceContributionsByAspectCode, v.properties.HasConferenceContributionAspectCode[1].fulltext) then
        table.insert(conferenceContributionsByAspectCode[v.properties.HasConferenceContributionAspectCode[1].fulltext], {
          conferenceContribution = v.conferenceContribution,
          properties = v.properties,
          content = page:getContent()
      })
      else
        conferenceContributionsByAspectCode[v.properties.HasConferenceContributionAspectCode[1].fulltext] = {{
          conferenceContribution = v.conferenceContribution,
          properties = v.properties,
          content = page:getContent()
        }}
      end
    end

    aspectCodesData = getAspectCodesData()

    -- Assemble tag cloud
    tagCloud = {}
    maxContributions = getMaxContributions(conferenceContributionsByAspectCode)
    minContributions = getMinContributions(conferenceContributionsByAspectCode)
    maxFontSize = 60
    minFontSize = 20
    for k,v in pairs(conferenceContributionsByAspectCode) do
      contributionTitlesList = getContributionTitlesList(v)
      aspectCodeGroup = aspectCodesData[k][1].properties.HasAspectCodeGroup[1]
      aspectCodeTitle = aspectCodesData[k][1].properties.HasEntityTitle[1]
      if aspectCodesData[k][1].properties.HasEntityBlurb[1] then
        aspectCodeBlurb = aspectCodesData[k][1].properties.HasEntityBlurb[1]
      else
        aspectCodeBlurb = ""
      end
      tooltip = mw.getCurrentFrame():preprocess( "{{#info: " .. aspectCodeBlurb .. " |note }}" )
      fontSize = minFontSize + ((table.getn(v) - minContributions) / (maxContributions - minContributions) * (maxFontSize - minFontSize))
      table.insert(tagCloud, "<div style=' \
background-color:" .. getBackgroundColorForAspectCodeGroup(aspectCodeGroup) .. "; \
margin:3px; \
padding:3px; \
display:inline; \
float:left; \
border-radius:5px; \
border:1px solid gray;'> \
<div style='font-size:14px;'>" .. aspectCodeGroup .. "</div> \
<div style='font-size:" .. fontSize .. "px;'>[[" .. k .. "|" .. aspectCodeTitle .. "]]" .. tooltip .. "</div> \
<div style='font-size:14px;'>" .. contributionTitlesList .. "</div> \
</div>")
    end

legend = "<div style=''><span style='background-color:#99FF99;'>PROMOTE/USE/MONITOR</span> | <span style='background-color:#99CCFF;'>DEVELOP/INTEGRATE</span> | <span style='background-color:#FF6666;'>SETUP/CONFIGURE/MAINTAIN</span> | <span style='border:1px solid gray;'>COMMUNITY</span></div>"

--    return table_print(aspectCodesData)
--    return table_print(conferenceContributionsByAspectCode)
    return "<div style='float:left;clear:right;border:1px solid gray;border-radius:2px;'>" .. legend .. "<hr>" .. table.concat(tagCloud, '&#32;') .. "</div>"
  end

  return conferenceContributionsQuery
end

-- HELPER FUNCTIONS

function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, key .. " = {\n");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function to_string( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        return tostring(tbl)
    end
end

function tableHasKey(table,key)
    return table[key] ~= nil
end

function getMaxContributions(conferenceContributionsByAspectCode)
  -- Get max amount of contributions per aspect code
  max = 0
  for k,v in pairs(conferenceContributionsByAspectCode) do
    if table.getn(v) > max then
      max = table.getn(v)
    end
  end
  return max
end

function getMinContributions(aspectCodes)
  -- Get min amount of contributions per aspect code
  min = 0
  for k,v in pairs(aspectCodes) do
    if table.getn(v) < min then
      min = table.getn(v)
    elseif min == 0 then
      min = table.getn(v)
    end
  end
  return min
end

function getAspectCodesData()
  local aspectCodesDataQuery = mw.smw.getQueryResult(" \
    [[HasAspectCodeGroup::+]] \
    |?HasAspectCodeGroup \
    |?HasEntityTitle \
    |?HasEntityBlurb \
  ")
  if aspectCodesDataQuery == nil then
    return "(no values)"
  end

  if type( aspectCodesDataQuery ) == "table" then
    aspectCodesData = {}
    for k,v in pairs( aspectCodesDataQuery.results ) do
      table.insert(aspectCodesData, {
        aspectCode = v.fulltext,
        properties = v.printouts
      } )
    end
  end

  -- Sort by AspectCode
  aspectCodes = {}
  for k,v in pairs(aspectCodesData) do
    if tableHasKey(aspectCodesData, v.aspectCode) then
      table.insert(aspectCodes[v.aspectCode], {
        properties = v.properties
    })
    else
      aspectCodes[v.aspectCode] = {{
        properties = v.properties
      }}
    end
  end

  return aspectCodes
end

function getBackgroundColorForAspectCodeGroup(aspectCode)
  green = { PROMOTE=true, USE=true, MONITOR=true }
  blue = { DEVELOP=true, INTEGRATE=true }
  red = { SETUP=true, CONFIGURE=true, MAINTAIN=true }
  if green[aspectCode] then
    return "#99FF99"
  elseif blue[aspectCode] then
    return "#99CCFF"
  elseif red[aspectCode] then
    return "#FF6666"
  else
    return "#FFFFFF"
  end
end

function getContributionTitlesList(conferenceContributions)
  ctl = {}
  for k,v in pairs(conferenceContributions) do
    if v.properties.HasEntityBlurb[1] then
      hasEntityBlurb = v.properties.HasEntityBlurb[1]
    else
      hasEntityBlurb = ""
    end
    volOfUpvotes = getVolOfUpvotes(v.content)
    tooltip = mw.getCurrentFrame():preprocess( "{{#info: " .. hasEntityBlurb .. " |note }}" )
    table.insert(ctl, "[[" .. v.conferenceContribution .. "|" .. v.properties.HasEntityTitle[1] .. "]] " .. tooltip .. " (" .. v.properties.HasConferenceContributionType[1] .. ", " .. volOfUpvotes .. " upvotes)")
  end
  return table.concat(ctl, '<br/>')
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function getVolOfUpvotes(content)
  allUpvotes = split(content, "Upvotes")[2]
  if allUpvotes then
    volUpvotes = #split(allUpvotes, "*")
  else
    volUpvotes = 1
  end
  return volUpvotes - 1
end

return p
