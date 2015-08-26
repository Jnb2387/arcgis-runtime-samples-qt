// Copyright 2015 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef OPEN_EXISTING_MAP_H
#define OPEN_EXISTING_MAP_H

#include "MapView.h"
#include "PortalItem.h"
#include <QPushButton>
#include <QMap>
#include <QInputDialog>

class OpenExistingMap : public QWidget
{
  Q_OBJECT

public:
  explicit OpenExistingMap(QWidget* parent = 0);
  virtual ~OpenExistingMap();

private:
  Esri::ArcGISRuntime::MapView* m_mapView;
  QPushButton* m_button;
  QInputDialog* m_inputDialog;
  QMap<QString, Esri::ArcGISRuntime::PortalItem> m_portalMaps;
  void createUi();
  void createPortalMaps();
};

#endif // OPEN_EXISTING_MAP_H
