function getMaxContributions(conferenceContributionsByAspectCode)
  -- Get max amount of contributions per aspect code
  max = 0
  for k,v in pairs(conferenceContributionsByAspectCode) do
    if #v > max then
      max = #v
    end
  end
  return max
end

function getMinContributions(aspectCodes)
  -- Get min amount of contributions per aspect code
  min = 0
  for k,v in pairs(aspectCodes) do
    if #v < min then
      min = #v
    elseif min == 0 then
      min = #v
    end
  end
  return min
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
    if v.properties.HasEntityBlurb then
      hasEntityBlurb = v.properties.HasEntityBlurb[1]
    else
      hasEntityBlurb = ""
    end
    tooltip = mw.getCurrentFrame():preprocess( "{{#info: " .. hasEntityBlurb .. " |note }}" )
    table.insert(ctl, "[[" .. v.conferenceContribution .. "|" .. v.properties.HasEntityTitle[1] .. "]] " .. tooltip .. " (" .. v.properties.HasConferenceContributionType[1] .. ")")
  end
  return table.concat(ctl, '<br/>')
end

aspectCodesData = {
  ["SE-2"] = {
    properties = {
      HasAspectCodeGroup = {
        "SETUP"
      },
      HasEntityTitle = {
        "Backends"
      }
    }
  },
  ["PR-2"] = {
    properties = {
      HasAspectCodeGroup = {
        "PROMOTE"
      },
      HasEntityTitle = {
        "Usage"
      },
      HasEntityBlurb = {
        "ACBlurb"
      }
    }
  }
}

conferenceContributionsByAspectCode = {
  ["SE-2"] = {
    {
      conferenceContribution = "CC1938198878",
      properties = {
        HasEntityTitle = {
          "Make it great"
        },
        HasConferenceContributionAspectCode = {
          exists = "1",
          displaytitle = "AspectCode \"Secure (Backup/Clone)\"",
          namespace = "0",
          fulltext = "MA-0",
          fullurl = "https://www.semantic-mediawiki.org/wiki/MA-0"
        },
        HasConferenceContributionType = {
          "Talk"
        },
        HasConferenceContributionStatus = {
          exists = "",
          displaytitle = "",
          namespace = "0",
          fulltext = "Accepted",
          fullurl = "https://www.semantic-mediawiki.org/wiki/Accepted"
        }
      }
    },
    {
      conferenceContribution = "CC1938198872",
      properties = {
        HasEntityTitle = {
          "Testing Lua in SMW"
        },
        HasEntityBlurb = {
          "ContribBlurb"
        },
        HasConferenceContributionAspectCode = {
          exists = "1",
          displaytitle = "AspectCode \"Secure (Backup/Clone)\"",
          namespace = "0",
          fulltext = "MA-0",
          fullurl = "https://www.semantic-mediawiki.org/wiki/MA-0"
        },
        HasConferenceContributionType = {
          "Talk"
        },
        HasConferenceContributionStatus = {
          exists = "",
          displaytitle = "",
          namespace = "0",
          fulltext = "Accepted",
          fullurl = "https://www.semantic-mediawiki.org/wiki/Accepted"
        }
      }
    }
  },
  ["PR-2"] = {
    {
      conferenceContribution = "CC1938198878",
      properties = {
        HasEntityTitle = {
          "Fundamental MW security/safety considerations for 3rd party users"
        },
        HasEntityBlurb = {
          "ContribBlurb"
        },
        HasConferenceContributionAspectCode = {
          exists = "1",
          displaytitle = "AspectCode \"Secure (Backup/Clone)\"",
          namespace = "0",
          fulltext = "MA-0",
          fullurl = "https://www.semantic-mediawiki.org/wiki/MA-0"
        },
        HasConferenceContributionType = {
          "Talk"
        },
        HasConferenceContributionStatus = {
          exists = "",
          displaytitle = "",
          namespace = "0",
          fulltext = "Accepted",
          fullurl = "https://www.semantic-mediawiki.org/wiki/Accepted"
        }
      }
    }
  }
}

tagCloud = {}
maxContributions = getMaxContributions(conferenceContributionsByAspectCode)
minContributions = getMinContributions(conferenceContributionsByAspectCode)
maxFontSize = 40
minFontSize = 20
for k,v in pairs(conferenceContributionsByAspectCode) do
  contributionTitlesList = getContributionTitlesList(v)
  aspectCodeGroup = aspectCodesData[k].properties.HasAspectCodeGroup[1]
  aspectCodeTitle = aspectCodesData[k].properties.HasEntityTitle[1]
  if aspectCodesData[k].properties.HasEntityBlurb then
    aspectCodeBlurb = aspectCodesData[k].properties.HasEntityBlurb[1]
  else
    aspectCodeBlurb = ""
  end
  fontSize = minFontSize + ((#v - minContributions) / (maxContributions - minContributions) * (maxFontSize - minFontSize))
  table.insert(tagCloud, "<div style=' \
background-color:" .. getBackgroundColorForAspectCodeGroup(aspectCodeGroup) .. "; \
margin:3px; \
padding:3px; \
display:inline; \
float:left; \
border-radius:5px; \
border:1px solid gray;'> \
<div style='font-size:14px;'>" .. aspectCodeGroup .. "</div> \
<div style='font-size:" .. fontSize .. "px;'>[[" .. k .. "|" .. aspectCodeTitle .. " {{#info: " .. aspectCodeBlurb .. " |note }}]]</div> \
<div style='font-size:14px;'>" .. contributionTitlesList .. "</div> \
</div>")
end

legend = "<div style=''><span style='background-color:#99FF99;'>PROMOTE/USE/MONITOR</span> | <span style='background-color:#99CCFF;'>DEVELOP/INTEGRATE</span> | <span style='background-color:#FF6666;'>SETUP/CONFIGURE/MAINTAIN</span> | <span style='border:1px solid gray;'>COMMUNITY</span></div>"

local file = io.open("example.html", "w")
file:write("<div style='float:left;clear:right;border:1px solid gray;border-radius:2px;'>" .. legend .. "<hr>" .. table.concat(tagCloud, '&#32;') .. "</div>")
file:close()
