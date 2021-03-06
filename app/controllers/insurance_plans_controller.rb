# frozen_string_literal: true

################################################################################
#
# Insurance Plans Controller
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

require 'json'

class InsurancePlansController < ApplicationController
  before_action :connect_to_server, only: [:index, :show]

  #-----------------------------------------------------------------------------

  # GET /insurance_plans/networks
  # The current test data doesn't link insurance plans to networks as of 11/8...probably need to rectify that, or fake it by linkages.
  def plan_networks (id)
    @network_list = @client.search(
  FHIR::Organization,
  search: { parameters: {
    _profile: 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-Network',
    partof: "Organization/#{id}"
  } }
)&.resource&.entry&.map do |entry|
  {
    value: entry&.resource&.id,
    name: entry&.resource&.name
  }
 end

end
    # GET /insurance_plans
    def index
    if params[:page].present?
      update_page(params[:page])
    else
      if params[:query_string].present?
        parameters = query_hash_from_string(params[:query_string])
        reply = @client.search(
                                FHIR::InsurancePlan,
                                search: {
                                  parameters: parameters.merge(
                                    _profile: 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-InsurancePlan'
                                  )
                                }
                              )
      else
        reply = @client.search(
          FHIR::InsurancePlan,
          search: {
            parameters: {
              _profile: 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-InsurancePlan'
            }
          }
        )

      end
      @bundle = reply.resource
      @search = "<Search String in Returned Bundle is empty>"
      @search = URI.decode(@bundle.link.select { |l| l.relation === "self"}.first.url) if @bundle.link.first 
     end

    update_bundle_links

    @query_params = query_params
    @insurance_plans = @bundle.entry.map(&:resource)

  end

  #-----------------------------------------------------------------------------

  # GET /insurance_plans/[id]

  def show
    reply = @client.search(FHIR::InsurancePlan,
                           search: { parameters: { _id: params[:id] } })
    bundle = reply.resource
    fhir_insurnace_plan = bundle.entry.map(&:resource).first

    @insurance_plan = InsurancePlan.new(fhir_insurnace_plan) unless fhir_insurnace_plan.nil?
   # plan_networks (params[:id])
  end

  def query_params
    [
      {
        name: 'Administered By',
        value: 'administered-by'
      },
      {
        name: 'Coverage Area',
        value: 'coverage-area'
      },
      {
        name: 'Coverage Benefit Type',
        value: 'coverage-benefit-type'
      },
      {
        name: 'Coverage Limit Value',
        value: 'coverage-limit-value'
      },
      {
        name: 'Coverage Network',
        value: 'coverage-network'
      },
      {
        name: 'Coverage Type',
        value: 'coverage-type'
      },
      {
        name: 'Endpoint',
        value: 'endpoint'
      },
      {
        name: 'General Cost Group Size',
        value: 'general-cost-groupsize'
      },
      {
        name: 'General Cost Type',
        value: 'general-cost-type'
      },
      {
        name: 'General Cost Value',
        value: 'general-cost-value'
      },
      {
        name: 'ID',
        value: '_id'
      },
      {
        name: 'Identifier',
        value: 'identifier'
      },
      {
        name: 'Name',
        value: 'name:contains'
      },
      {
        name: 'Network',
        value: 'network'
      },
      {
        name: 'Owned By',
        value: 'owned-by'
      },
      {
        name: 'Plan Coverage Area',
        value: 'plan-coverage-area'
      },
      {
        name: 'Plan Identifier',
        value: 'plan-identifier'
      },
      {
        name: 'Plan Network',
        value: 'plan-network'
      },
      {
        name: 'Plan Type',
        value: 'plan-type'
      },
      {
        name: 'Specific Cost Benefit Type',
        value: 'specific-cost-benefit-type'
      },
      {
        name: 'Specific Cost Category',
        value: 'specific-cost-category'
      },
      {
        name: 'Specific Cost Type',
        value: 'specific-cost-type'
      },
      {
        name: 'Specific Cost Value',
        value: 'specific-cost-value'
      },
      {
        name: 'Status',
        value: 'status'
      },
      {
        name: 'Type',
        value: 'type'
      }
    ]
  end
end
