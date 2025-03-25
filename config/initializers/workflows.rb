Rails.application.config.after_initialize do
  parcel_workflow = Workflow.new(
    id: 'add_parcel',
    name: 'Add Parcel',
    description: 'Helps you add a new parcel with associated structures by providing just an address.',
    schema_class: 'ParcelEntrySchema',
    trigger_phrases: [
      'add a parcel',
      'create a parcel',
      'new parcel',
      'add property',
      'create property'
    ],
    input_instructions: 'Please provide the address of the parcel you want to add.',
    output_path: 'review_parcel_path'
  )

  Workflow.register(parcel_workflow)
end
