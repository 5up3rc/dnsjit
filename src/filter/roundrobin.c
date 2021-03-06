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

#include "config.h"

#include "filter/roundrobin.h"

static core_log_t          _log      = LOG_T_INIT("filter.roundrobin");
static filter_roundrobin_t _defaults = {
    LOG_T_INIT_OBJ("filter.roundrobin"), 0, 0
};

core_log_t* filter_roundrobin_log()
{
    return &_log;
}

int filter_roundrobin_init(filter_roundrobin_t* self)
{
    if (!self) {
        return 1;
    }

    *self = _defaults;

    ldebug("init");

    return 0;
}

int filter_roundrobin_destroy(filter_roundrobin_t* self)
{
    filter_roundrobin_recv_t* r;
    if (!self) {
        return 1;
    }

    ldebug("destroy");

    while ((r = self->recv_list)) {
        self->recv_list = r->next;
        free(r);
    }

    return 0;
}

int filter_roundrobin_add(filter_roundrobin_t* self, core_receiver_t recv, void* robj)
{
    filter_roundrobin_recv_t* r;
    if (!self) {
        return 1;
    }

    ldebug("add recv %p obj %p", recv, robj);

    if (!(r = malloc(sizeof(filter_roundrobin_recv_t)))) {
        return 1;
    }

    r->next         = self->recv_list;
    r->recv         = recv;
    r->robj         = robj;
    self->recv_list = r;

    if (!self->recv) {
        self->recv = self->recv_list;
    }

    return 0;
}

static int _receive(void* robj, core_query_t* q)
{
    filter_roundrobin_t* self = (filter_roundrobin_t*)robj;

    if (!self || !q || !self->recv) {
        core_query_free(q);
        return 1;
    }

    self->recv->recv(self->recv->robj, q);
    self->recv = self->recv->next;
    if (!self->recv) {
        self->recv = self->recv_list;
    }

    return 0;
}

core_receiver_t filter_roundrobin_receiver()
{
    return _receive;
}
