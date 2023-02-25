/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.smartevents.qute.demo;

import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.qute.QuteConstants;
import org.apache.camel.model.dataformat.JsonLibrary;

import java.util.Map;

public class SmartEventsRoute extends RouteBuilder {
    @Override
    public void configure() throws Exception {

        from("kafka:inbound")
                .unmarshal().json(JsonLibrary.Jackson, Map.class)
                .setHeader(QuteConstants.QUTE_TEMPLATE)
                    .constant("{#if body.data.context.display_name??}\n" +
                            "<{body.data.environment_url}{#if body.data.bundle == \"openshift\" and body.data.application == \"advisor\"}/openshift/insights/advisor/clusters/{body.data.context.display_name}{#else}/insights/inventory/{#if body.data.context.inventory_id??}{body.data.context.inventory_id}{#else}?hostname_or_id={body.data.context.display_name}{/if}{/if}|{body.data.context.display_name}> triggered {body.data.events.size()} event{#if body.data.events.size() > 1}s{/if}{#else}\n" +
                            "{body.data.events.size()} event{#if body.data.events.size() > 1}s{/if} triggered{/if} from {body.data.bundle}/{body.data.application}. <{body.data.environment_url}/{#if body.data.bundle == \"application-services\" and body.data.application == \"rhosak\"}application-services/streams{#else}{#if body.data.bundle == \"openshift\"}openshift/{/if}insights/{body.data.application}{/if}|Open {body.data.application}>")
                .to("qute:hello?allowTemplateFromHeader=true")
                .to("kafka:outbound");
    }
}