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

package main

import (
	"encoding/json"
	"net/http"
	"net/url"
	"strings"
)

func wellKnownHandler(w http.ResponseWriter, r *http.Request) {
	// Detect if the request was made with SSL.
	ssl := r.TLS != nil
	scheme := "http"
	proto, ok := r.Header["X-Forwarded-Proto"]
	if ok {
		ssl = proto[0] == "https"
	}
	if ssl {
		scheme = "https"
	}

	// Construct our URL.
	url := url.URL{
		Scheme: scheme,
		Host:   r.Host,
		Path:   strings.TrimSuffix(config.B, "/"),
	}
	doc := &map[string]string{
		"open-rtc_endpoint": url.String(),
	}
	data, err := json.MarshalIndent(doc, "", "  ")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(data)
}
