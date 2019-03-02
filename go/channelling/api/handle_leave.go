/*
 * Open-RTC.
 * Copyright (C) 2013-2016 struktur AG
 * Copyright 2019 - deroad
 *
 * This file is part of Open-RTC.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

package api

import (
	"github.com/wargio/open-rtc/go/channelling"
)

func (api *channellingAPI) HandleLeave(session *channelling.Session) error {
	session.LeaveRoom()

	return nil
}
