/*
 * Open-RTC.
 * Copyright (C) 2013-2015 struktur AG
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

"use strict";
define([], function() {

	// modules
	return ["mediaStream", function(mediaStream) {

		var enabledModules = mediaStream.config.Modules || [];

		// Public api.
		return {
			withModule: function(m) {
				return enabledModules.indexOf(m) !== -1;
			}
		}

	}];
});
