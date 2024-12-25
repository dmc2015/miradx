# frozen_string_literal: true

Rails.application.routes.draw do
  resources :risk_analyses, only: [:create]
  root 'rails/welcome#index'
end
