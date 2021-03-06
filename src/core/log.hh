/*
 * Copyright (c) 2018, OARC, Inc.
 * All rights reserved.
 *
 * This file is part of dnsjit.
 *
 * dnsjit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * dnsjit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with dnsjit.  If not, see <http://www.gnu.org/licenses/>.
 */

typedef struct core_log_settings {
    unsigned short debug : 2;
    unsigned short info : 2;
    unsigned short notice : 2;
    unsigned short warning : 2;
    unsigned short display_file_line : 2;
} core_log_settings_t;

typedef struct core_log {
    const char*                name;
    unsigned short             is_obj : 1;
    core_log_settings_t        settings;
    const core_log_settings_t* module;
} core_log_t;

void core_log_debug(const core_log_t* l, const char* file, size_t line, const char* msg, ...);
void core_log_info(const core_log_t* l, const char* file, size_t line, const char* msg, ...);
void core_log_notice(const core_log_t* l, const char* file, size_t line, const char* msg, ...);
void core_log_warning(const core_log_t* l, const char* file, size_t line, const char* msg, ...);
void core_log_critical(const core_log_t* l, const char* file, size_t line, const char* msg, ...);
void core_log_fatal(const core_log_t* l, const char* file, size_t line, const char* msg, ...);

core_log_t* core_log_log();
