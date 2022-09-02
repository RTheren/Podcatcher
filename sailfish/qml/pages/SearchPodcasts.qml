/**
 * This file is part of Podcatcher for Sailfish OS.
 * Authors: Johan Paul (johan.paul@gmail.com)
 *          Moritz Carmesin (carolus@carmesinus.de)
 *
 * Podcatcher for Sailfish OS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Podcatcher for Sailfish OS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Podcatcher for Sailfish OS.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0


Page {
    id: browsePage
    property var  searchProvider:  searchITunesPodcastsModel.model

    allowedOrientations: Orientation.All

    SilicaFlickable{
        anchors.fill: parent
        //orientationLock: PageOrientation.LockPortrait


        PullDownMenu {


            MenuItem {
                text: qsTr("Import podcasts from gPodder")
                onClicked: {
                    pageStack.push(importFromGPodderComponent)

                }
            }

            MenuItem {
                text: qsTr("Add URL manually")
                onClicked: {
                    pageStack.push(addNewPodcastComponent)
                }
            }
        }


        BusyIndicator  {
            id: loadingIndicator
            anchors.centerIn: parent
            visible: (searchGPodderPodcastsModel.status == XmlListModel.Loading );
            running: (searchGPodderPodcastsModel.status == XmlListModel.Loading );
            size: BusyIndicatorSize.Large
        }

        Item {
            anchors.centerIn: parent;
            visible: (searchGPodderPodcastsModel.status != XmlListModel.Loading &&
                      searchWord.focus == false &
                      searchPodcastsList.count == 0);
            Label {
                anchors.centerIn: parent
                text: qsTr("No podcasts found.")
                font.pixelSize: 35
                font.bold: true
            }
        }

        Column {
            id: searchPageColumn
            anchors.fill: parent
            spacing: Theme.paddingSmall
            anchors{
                //leftMargin: Theme.horizontalPageMargin
                rightMargin: Theme.horizontalPageMargin
                bottomMargin: Theme.paddingMedium
            }

            PageHeader{
                id: searchPageTitle
                title: qsTr("Search podcasts")
            }

            SearchField {
                id: searchWord
                placeholderText: qsTr("Keyword")

                width: parent.width

                Keys.onReturnPressed: {
                    parent.focus = true;
                    searchGPodderPodcastsModel.source = "http://gpodder.net/search.xml?q=\"" + searchWord.text+"\"";
                    searchITunesPodcastsModel.source =  "https://itunes.apple.com/search?media=podcast&term="+encodeURIComponent(searchWord.text);

                }

                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-search"
            }
            ComboBox{
                id: cbSearchProvider
                width:parent.width
//                anchors.top: searchWord.bottom
//                anchors.topMargin: Theme.paddingSmall
                label: qsTr("Search at")
                menu: ContextMenu{
                    MenuItem{text: qsTr("gPodder")
                        onClicked: {
                            searchProvider = searchGPodderPodcastsModel;
                        }
                    }
                    MenuItem{text: qsTr("Apple")
                        onClicked: {
                            searchProvider = searchITunesPodcastsModel.model;
                        }
                    }
                }
            }

            SilicaListView {
                id: searchPodcastsList
                //model: searchGPodderPodcastsModel
                model: searchProvider
                width: parent.width
                height: parent.height - searchWord.height - searchPageTitle.height-cbSearchProvider.height - 3*Theme.paddingSmall - Theme.paddingMedium
                //anchors.horizontalCenter: parent.horizontalCenter
                //anchors.top: cbSearchProvider.bottom
                clip: true
                visible: false
                spacing:0// Theme.paddingMedium

                delegate:
                    ListItem {
                    id: searchItem
                    contentHeight: Math.max(channelNameItem.height, channelLogo.height)
                    width: parent.width


                    Image {
                        id: channelLogo;
                        source: model.logo?model.logo:model.artworkUrl100
                        //source: artworkUrl100
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width:  height
                        height: Theme.itemSizeLarge;
                        visible: status == Image.Ready
                    }

                    BusyIndicator  {
                        id: loadingIndicatorEpisode
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        visible: (channelLogo.status != Image.Ready);
                        running: (channelLogo.status != Image.Ready);
                    }

                    Item {
                        id: channelNameItem
                        anchors.left: channelLogo.right
                        anchors.leftMargin: Theme.paddingMedium;
                        width: searchItem.width - channelLogo.width - Theme.paddingMedium

                        height: channelName.height + Theme.paddingSmall + channelUrl.height

                        //                        height: parent.height

                        //                        Column {
                        //                            width: parent.width
                        //                            spacing: Theme.paddingSmall

                        //                            Row {
                        //                                width: parent.width

                        Label {
                            id: channelName;
                            text: model.title?model.title:model.collectionName
                            //text: collectionName
                            //truncationMode: TruncationMode.Fade
                            wrapMode: Text.Wrap
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Theme.fontSizeMedium
                            color: channelNameItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                            width: parent.width - subscribeButton.width - Theme.paddingMedium
                            //height: channelNameItem.height - channelUrl.height - Theme.paddingSmall
                            height: Text.paintedHeight


                        }

                        IconButton{

                            id: subscribeButton
                            anchors.leftMargin: Theme.paddingMedium
                            anchors.left: channelName.right

                            icon.source: "image://theme/icon-m-add"

                            onClicked: {
                                console.log("Subscribe to podcast with url: " + model.url?model.url:model.feedUrl)
                                mainPage.addPodcast(model.url?model.url:model.feedUrl, model.logoUrl?model.logoUrl:model.artworkUrl100);
                                pageStack.pop(mainPage);
                            }
                        }

                        //                            }

                        Label {
                            id: channelUrl;
                            anchors.top: channelName.bottom
                            anchors.topMargin: Theme.paddingSmall
                            text: model.url?model.url:model.feedUrl
                            //text: feedUrl
                            font.pixelSize: Theme.fontSizeTiny
                            color: channelNameItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                            width: parent.width
                            truncationMode: TruncationMode.Elide
                        }

                    }
                }
                //                }

                XmlListModel {
                    id: searchGPodderPodcastsModel
                    query: "/podcasts/podcast"

                    XmlRole { name: "logo"; query: "logo_url/string()" }
                    XmlRole { name: "title"; query: "title/string()" }
                    XmlRole { name: "url"; query: "url/string()" }
                    XmlRole { name: "logoUrl"; query: "logo_url/string()" }

                    onStatusChanged: {
                        console.log("XML loading status changed: " + status);
                        console.log("XML error: " + searchGPodderPodcastsModel.errorString());
                    }
                }

                JSONListModel{
                    id: searchITunesPodcastsModel
                    query: "$..results[*]"
                }


                VerticalScrollDecorator{}
            }
        }

        Component.onCompleted: {
            searchWord.forceActiveFocus()
        }

        states: [
            State {
                name: 'searchLoaded'; when: searchGPodderPodcastsModel.status == XmlListModel.Ready
                PropertyChanges {
                    target: searchPodcastsList
                    visible: true
                }
            }
        ]
    }

    Component{
        id: importFromGPodderComponent
        ImportFromGPodder{

        }
    }

    Component{
        id: addNewPodcastComponent
        Dialog {
            id: addNewPodcastSheet


            Column {
                id: col
                anchors.fill: parent
                spacing: Theme.paddingMedium

                DialogHeader{
                    title: qsTr("Add new podcast")
                    acceptText: qsTr("Add")
                }

                TextField {
                    id: podcastUrl
                    placeholderText: qsTr("Podcast RSS URL")
                    width: parent.width

                    Keys.onReturnPressed: {
                        parent.focus = true;
                    }
                }
            }

            onStatusChanged: {
                if (status == DialogStatus.Opening) {
                    podcastUrl.text = ""
                }

            }

            onAccepted: {
                mainPage.addPodcast(podcastUrl.text, "");
                pageStack.pop(mainPage);
            }
        }
    }
}
