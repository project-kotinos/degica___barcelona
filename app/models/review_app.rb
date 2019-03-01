class ReviewApp < ApplicationRecord
  belongs_to :heritage, dependent: :destroy, autosave: true
  belongs_to :review_group

  attr_accessor :image_name, :image_tag, :service_params, :before_deploy, :environment
  validates :subject, :image_name, :image_tag, :retention_hours, :service_params, presence: true
  validates :subject, format: {with: /\A[a-z0-9][a-z0-9-]*[a-z0-9]\z/}

  before_validation :build_heritage
  after_save :deploy

  def build_heritage
    params = {
      name: "review-#{slug_digest}",
      image_name: image_name,
      image_tag: image_tag,
      before_deploy: before_deploy,
      environment: environment,
      services: [
        service_params.merge(
          name: "review",
          listeners: [
            {
              endpoint: review_group.endpoint.name,
              rule_priority: rule_priority_from_subject,
              rule_conditions: [{type: "host-header", value: domain}]
            }
          ]
        )
      ]
    }

    self.heritage = BuildHeritage.new(params, district: review_group.district).execute
  end

  def deploy
    touch
    self.heritage.deploy!(description: "ReviewApp for #{subject}")
    CleanupReviewAppJob.set(wait: retention_hours.hours).perform_later(self)
  end

  def domain
    "#{subject}.#{review_group.base_domain}"
  end

  def rule_priority_from_subject
    (slug_digest.to_i(16) % 50000) + 1
  end

  def slug
    review_group.name + "---" + subject
  end

  def slug_digest
    Digest::SHA256.hexdigest(slug)[0...8]
  end

  def to_param
    subject
  end

  def expired?(now=Time.current)
    updated_at < (now - retention_hours.hours)
  end
end
